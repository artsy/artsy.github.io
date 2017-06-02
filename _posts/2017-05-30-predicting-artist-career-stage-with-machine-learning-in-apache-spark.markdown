---
layout: post
title: "Predicting Artist Career Stage with Machine Learning in Apache Spark"
date: 2017-05-30
comments: true
author: db
categories: [Big Data, Apache Spark]
---
How established is an artist? Our answer is a fairly subjective value that we call _career stage_. An artist who has passed away, recently had a retrospective in a major museum, or demanded high prices at auction has a high career stage value, while a fairly unknown up-and-coming young artist has a low one. The [Art Genome](https://www.artsy.net/categories) historians classified around 25,000 artists in our database by hand, and we predict the career stages of the other 50,000 or so artists using machine learning in Apache Spark.

<!-- more -->

### Extracting Features

First, we retrieve artist features, such as the top price fetched at auction and artist age along with manually assigned career stage value. We do this by querying Hive, which is the access layer for data stored on our distributed file system (HDFS).

```scala
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.hive.HiveContext
import org.joda.time.DateTime

case class Features(
  artistId:        String,
  careerStageGene: Double,
  age:             Int,
  maxPrice:        Double
)

private def extractFeatures(hc: HiveContext): RDD[Features] = {
  hc.sql(
    s"""SELECT
       |  artist_id,
       |  career_stage_gene,
       |  birthday,
       |  max_price_in_auctions
       |FROM
       |  data.artists
       |""".stripMargin
  ).rdd.map { row =>
    Features(
      artistId        = row.getString(0),
      careerStageGene = row.getDouble(1),
      age             = DateTime.now.getYear - Try(DateTime.parse(row.getString(2)).getYear).getOrElse(DateTime.now.getYear),
      maxPrice        = row.getDouble(3)
    )
  }
}
```

Features are packed in a vector to become usable by the built-in Spark functions. We're not using the manually entered career stage gene as input, so it's not part of the feature vector.

```scala
import org.apache.spark.mllib.linalg._

case class Features(
   ...
) = {
  def vector: Vector = {
    Vectors.dense(
      age.toDouble,
      maxPrice
    )
  }

```

### Normalizing and Weighing Features

Since fetching a million dollars at auction isn't a million times more important than an artist's age, we must normalize values. We create a scaler to be used in both the training and the prediction parts of the code.

```scala
import org.apache.spark.mllib.feature.StandardScaler

val scaler = new StandardScaler().fit(features.map(f => f.vector))
```

### Preparing Training Points

Our training data contains all the artists that have a manual value for a career stage gene. The input is the scaled vector of features and the output is the known career stage value.

```scala
val featuresForTraining = features.filter(feature => feature.careerStageGene > 0)
val labeledPointsForTraining = featuresForTraining.map {
  f => LabeledPoint(f.careerStageGene, scaler.transform(f.vector))
}
```

### Training a Model

We use a linear regression with stochastic gradient descent (SGD) as the learning scheme. This will yield coefficients for each feature along with an intercept (the value of career stage when the input features are zero) and train it. The optimizer options below are the default, but may need some experimenting depending on input data.

```scala
import org.apache.spark.mllib.regression._

val model = new LinearRegressionWithSGD()
model.optimizer.setNumIterations(100)
model.optimizer.setStepSize(1.0)
model.optimizer.setMiniBatchFraction(1.0)
model.setIntercept(true)

val trainedModel = model.run(labeledPointsForTraining)

logInfo(s"weights: ${trainedModel.weights}, intercept: ${trainedModel.intercept}")
```

We can use the generated model to run predictions on known data and compare results using `RegressionMetrics`.

```scala
import org.apache.spark.mllib.evaluation._

val predictionsAndObservations = labeledPointsForTraining.map { point =>
  val prediction = model.predict(point.features)
  (prediction, point.label)
}

val metrics = new RegressionMetrics(predictionsAndObservations)

logInfo(s"mean squared error: ${metrics.meanSquaredError}")
logInfo(s"r2=${metrics.r2}")
logInfo(s"explained variance=${metrics.explainedVariance}")
```

The lower the Mean Squared Error (MSE), the better the fit achieved by our linear regressor. The MSE is used to guide the gradient descent process as it searches for the best fit.

### Predicting Career Stage

Same operation, but using artists that don't have a career stage value.

```scala
val featuresForPredicting = features.filter(feature => feature.careerStageGene == 0)

val results = featuresForPredicting.map { feature =>
  val predictedCareerStage = trainedModel.predict(scaler.transform(feature.vector))
  (feature.artistId, predictedCareerStage)
}
```

### Tests

After refactoring the above functionality into `train` and `predict` functions we can write some tests.

```scala
import net.artsy.utils.SparkSpec
import org.apache.spark.mllib.feature.StandardScaler
import org.apache.spark.mllib.regression.LabeledPoint

"train" should "train a model with intercept" in {
  val featuresForTraining = Array(
    Features(artistId = "1", careerStageGene = 50.0, age = 50, maxPrice = 10.0),
    Features(artistId = "2", careerStageGene = 60.0, age = 60, maxPrice = 20.0),
    Features(artistId = "3", careerStageGene = 40.0, age = 0, maxPrice = 0)
  )

  val scaler = new StandardScaler().fit(sc.parallelize(featuresForTraining.map(f => f.vector)))
  val labeledPointsForTraining = featuresForTraining.map {
    f => LabeledPoint(f.careerStageGene, scaler.transform(f.vector))
  }
  val trainedModel = train(sc.parallelize(labeledPointsForTraining))

  trainedModel.weights.numActives should equal(2)
  trainedModel.intercept should equal(40.0 +- 1.5)
}

"predict" should "predict career stage genes" in {
  val features = Array(
    Features(artistId = "1", careerStageGene = 50.0, age = 50, maxPrice = 10.0),
    Features(artistId = "2", careerStageGene = 60.0, age = 60, maxPrice = 20.0),
    Features(artistId = "3", careerStageGene = 40.0, age = 0, maxPrice = 0),
    Features(artistId = "4", careerStageGene = 0.0, age = 55, maxPrice = 15.0),
    Features(artistId = "5", careerStageGene = 0.0, age = 35, maxPrice = 75.0)
  )

  val predictions = predict(sc.parallelize(features)).collect().toMap
  predictions.get("4").get should equal(55.0 +- 1)
  predictions.get("5").get should equal(58.5 +- 1)
}
```

### Conclusion

Use the above walkthrough as a cookbook. For more Spark examples at Artsy see [Calculating the Importance of an Artwork](/blog/2017/04/21/calculating-the-importance-of-an-artwork-with-apache-spark) and [Generating Sitemaps](/blog/2017/04/02/generating-sitemaps-with-apache-spark).

