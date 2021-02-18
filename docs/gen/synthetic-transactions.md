# Synthetic Transactions

One of the most important aspects of Heracles is that a consistent set of behaviours are seen across the Application Insights instances that are used to monitor the application.  This means that you can familiarise youself with what's been happening and how its manifests itself in Application Insights, and this, in turn lets you learn.

All data generation occurs in an Azure Function called <your-alias>heracles-gen-func:
  
![a screenshot of a function app](../images/hercheracles-functionapp.jpg)

The two functions we are interested in are:

- HereclesGeneratorTimerTrigger
- HereclesGeneratorHttpTrigger

HereclesGeneratorTimerTrigger fires every 5 minutes and geenrates a random number of transactions, for a random set of Labours.  This gives consistent but different monitoring every time, similar enought that you can learn, but different enough to provide variety in what we see.

You can also [mnaually trigger a generation](manually-trigger-generation.md) run using a browser.


