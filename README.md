# Service Map REST API samples

You probably know what [Azure Service Map](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/Microsoft.ServiceMapOMS?tab=Overview) is: a service that can analyze traffic in your data center and display application dependencies. This can be extremely useful for different purposes, such as deciding which VMs can be moved to the public cloud, and in which order.

At the time of this writing there is no SDK to Azure Service Map, but there are some REST APIs. Unfortunately the [Service Map REST API Reference documentation](https://docs.microsoft.com/rest/api/servicemap/) is not too rich in examples, so I compiled a Postman library and a Powershell script with sample code that demonstrates how to use Azure Service Map REST API.

The examples cover:

* Authentication (using a service principal)

* Listing virtual machines reporting information to Service Map

* Listing VM groups configured in Service Map

* Adding VMs to to VM groups

Have fun with Azure Service Map!