

"Entry points"
 
- force/eigen
- volt
- gravity
- fulcrum


Gravity
 - Elasticsearch
 - 

force + eigen talk to graphQL (metaphysics)
graphQL talks to 
  - Gravity
  - Causality (Auctions)
  - Positron (Editorial API)
  - Galaxy (galleries, fairs and auction houses)

CMS (volt) talks to:
 -  Lewitt (Invoicing)
 - admin metadata
 - sandback?
 - positron
 - galaxy
 - gemini
 - impulse
 - radiation
 - tangent

Auctions:
  Front-end -> Causality
  Gravity <-> Causality

Image uploading: 
  volt -> gemini -> s3

User Messaging: 
  volt + radiation -> impulse -> sendgrid

System Notifications:


Analytics:
  
  Gravity rakes tasks generate daily reports:
    fulcrum talks to saleforce, ga, mongo, sailthru
    fulcrum -> aws s3 -> redshift -> looker
    fulcrum -> causality api -> redshift
  
  Reading:
    Jupyter Notebooks + Looker -> Looker

Data processing:
  Hadoop Cluster -> Spark jobs -> S3 -> Gravity

For more info on [the analytics](https://docs.google.com/presentation/d/1qIun-H92xnzJAIh44X9_0pJtvXuzVBaGOZaWQZSPvBY/edit#slide=id.g18d68486af_0_341)
