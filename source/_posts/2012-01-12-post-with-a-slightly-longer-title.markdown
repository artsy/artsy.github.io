---
layout: post
title: "Post With a Very, Very Long Title That Wraps"
date: 2012-01-12 12:04
comments: true
categories: 
---

Here is some sample text for the post. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla scelerisque tempor libero id placerat. Quisque rhoncus vehicula turpis, sit amet scelerisque lacus aliquam sed. Fusce vitae sapien nisi. Aenean diam purus, rhoncus a faucibus vitae, congue sed eros. Suspendisse tristique eros vel quam fermentum nec aliquam eros egestas. Here's a link to a [great webpage](http://google.com). In hac habitasse platea dictumst. Proin urna ligula, mollis et tempor sed, pharetra ac nibh. Pellentesque purus velit, adipiscing sed mollis sed, varius eu ligula. Suspendisse accumsan enim vitae lectus scelerisque rutrum. Cras posuere, nunc id sodales congue, magna arcu facilisis velit, sed fringilla nisl mi at velit.

Here's how you code:

    module Date

      # Returns a datetime if the input is a string
      def datetime(date)
        if date.class == String
          date = Time.parse(date)
        end
        date
      end

      # Returns an ordidinal date eg July 22 2007 -> July 22nd 2007
      def ordinalize(date)
        date = datetime(date)
        "#{date.strftime('%b')}"
      end

      # Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
      def ordinal(number)
        if (11..13).include?(number.to_i % 100)
          "#{number}<span>th</span>"
        else
          case number.to_i % 10
          when 1; "#{number}<span>st</span>"
          when 2; "#{number}<span>nd</span>"
          when 3; "#{number}<span>rd</span>"
          else    "#{number}<span>th</span>"
          end
        end
      end
    end

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Morbi arcu augue, imperdiet nec consectetur id, laoreet vitae metus. Aliquam vitae ipsum quis turpis congue malesuada vitae quis ipsum. Maecenas lobortis mollis vestibulum. Phasellus sagittis rhoncus justo, vel commodo lorem lacinia eget. Integer id vulputate sapien. Curabitur odio nisl, rutrum a condimentum in, vulputate eget ipsum. Curabitur interdum eros at nunc dignissim commodo.

Curabitur viverra tincidunt sem, nec rhoncus tellus ultrices eu. Cras convallis, tellus non auctor tempor, leo justo euismod enim, at blandit dui quam eget libero. Vivamus pulvinar elit nec nisi varius adipiscing. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed accumsan tempus mauris, at lacinia dolor condimentum vel. Nullam lorem odio, vulputate in iaculis id, blandit eu tellus. Vestibulum a risus non elit tincidunt hendrerit. Ut ut semper quam. Morbi at egestas augue. Nullam aliquam faucibus blandit. Aliquam accumsan fermentum porttitor. Suspendisse sit amet porta sem. Donec at neque et justo sollicitudin elementum id quis velit. Ut eget metus at lorem convallis luctus a non ligula.

Duis quis arcu ipsum. Vestibulum pharetra, ligula ac cursus rhoncus, magna felis tempus tellus, eget bibendum magna risus vitae sem. Pellentesque nibh diam, varius at congue ut, ornare non elit. Nulla ac vestibulum est. Duis tincidunt diam sagittis erat vestibulum lacinia. Donec non consequat odio. Ut consectetur, arcu in placerat aliquam, sapien sem elementum justo, aliquet malesuada nisl arcu et nisi. Nunc vitae libero ac dolor viverra ornare. Mauris pellentesque rutrum porta. Aenean orci eros, dapibus vel tempus in, lacinia ut mauris. Integer ut mattis libero. Nulla sit amet tortor a sem semper luctus. Etiam lobortis metus eu elit ullamcorper non adipiscing augue sodales. Phasellus commodo iaculis libero, a ornare justo mollis et. Maecenas elementum porta dolor, sit amet volutpat mauris gravida eu.

Maecenas mollis lobortis turpis, eu tincidunt urna cursus sed. Aliquam erat volutpat. Proin convallis enim mattis felis consectetur pharetra. Integer bibendum porttitor facilisis. Duis ut aliquet sem. Vivamus et consequat lorem. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis accumsan nisl in enim porta bibendum. Integer ac neque ut enim pulvinar pellentesque.