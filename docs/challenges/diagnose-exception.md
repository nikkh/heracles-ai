# Diagnose an Exception

This activity is designed to help you find your way around Application Insights.  Imagine we have just made a deployment of our application to a staging site, and we want to direct a small amount of user traffic to that site so we can check the behaviour of the release before rolling it out more widely.
 
Well actually, we have just deployed our application – let’s have a look at how its behaving.  First, we need to [generate some traffic](heracles-generator-manual.md) to our site.  
Open the Application Insights instance for chania-web, and choose Live Metrics.  Whlie watching the Live Metrics screen, then generate some more traffic.  Now you should see transactions being processed in the Live Metrics window.  Keep pressing enter on the generator until you have seen at least one exception in the Sample Telemetry windows in Live Metrics.

This is simulating what we might see if we were looking at Live Metrics during a blue-green or canary release to our production environment.  And we have just seen an exception!  At this point we would point all our traffic back to the previous version of our site and we can now diagnose the exceptions, comfortable in the knowledge that our Live Site is still functioning.

In the menu for chania-web application insights, choose Exceptions.

## The challenge

1. Which Labour of Heracles generated the most exceptions during our test?
1. Which line of code is at fault and causing these exceptions?

[Check your answers...](diagnose-exception-answer.md)

 
