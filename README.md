# sapiocon-24-python

[![License](https://img.shields.io/pypi/l/sapiopylib.svg)](https://github.com/sapiosciences/sapio-py-tutorials/blob/master/LICENSE)

## What is it

This project contains the Sapio Python Webhook examples that were shown
at [SAPIOCON 2024](https://www.sapiosciences.com/sapiocon)

### What is included

`SAPIOCON.ssg` is a synergy that contains a SapioCon data type that is designed to be used with the action button
and selection list examples here

`server.py` is the entry point for the python server that will host the webhook. It will configure the server and then
start it

`webhook/2024/ActionButtonExample.py` is an example of an action button webhook that will call an external library and run an analysis on a Sample record

`webhook/2024/ELNRuleExample.py` is an example ELN Rule Action webhook that will add the plates from the samples onto a Plates entry

`webhook/2024/MainToolbarExample.py` is an example of looking up a template, creating an experiment, and returning a client directive to it

`webhook/2024/ScheduledRuleExample.py` is an example of a schedule rule webhook that will look up the unassigned samples for the day and assign them to a technician

`webhook/2024/TableToolbarExample.py` is an example of a Samples toolbar button where an experiment from a template will be created, adding the selected samples to it, and returning a client directive to it

`webhook/2023/action_button.py` is an example of a webhook that will be called when a user clicks on an action button in the
UI. This webhook shows an example of how showing a client callback works

`webhook/2023/custom_report.py` is a simple webhook demonstrating how you can directive the user to a Custom Report search result.

`webhook/2023/hello_world.py` is a bare-bones webhook that you can use to verify that your Sapio System is successfully
communicating with your webhook

`webhook/2023/list_homeworld.py` is a selection list webhook that will return a list of planets to be used by a selection
list in Sapio

`webhook/2023/list_technicians.py` is a selection list webhook that will return a list of technicians to be used by a
selection list in Sapio

`webhook/2023/load_instrument_data.py` is a ELN webhook that will mimic loading instrument data and inserting into your
active entry

`webhook/2023/record_model.py` is a webhook that shows how to use the Record Model to retrieve/updated/create Data Records

## Requirements

This project depends on [sapiopylib](https://pypi.org/project/sapiopylib/)

For the `ROOT` `/` path to load it depends on the [markdown](https://pypi.org/project/Markdown/) package being installed
to generate the HTML

For SAPIOCON 24 we ran it on render.com for ease of use, but you can run it locally or anywhere you can run python and
host a webserver as long as your Sapio System can reach it.

## Building

Included with this project is a requirements.txt file that allows for you to quickly install the dependencies
through `pip`
> `pip install -r requirements.txt`

## Running

#### In production, you should use gunicorn. This requires linux and gunicorn pip dependency to be installed
> `gunicorn server:app`
#### If you want to run locally for development you can launch with python & waitress
> `python -u server.py`

The `-u` unbuffered parameter is used so that the stdout/stderr console output isn't buffered, so it doesn't need to be
flushed before being shown.

For development of your own custom webhooks we recommend starting with at least 1vCPU and 2gb RAM. Since machine requirements are highly dependent on what your custom code is doing it's recommended to monitor system metrics and scale the server based on need. You can use any OS that can run Python 3, but for server hosting we use Ubuntu 22.04 and if using docker we use the `python:3-slim` docker python image from the public [Docker Repo](https://hub.docker.com/_/python).

## Deploying to AWS/Production

For an example of how we recommend a production setup of a webhook server we've included a `Dockerfile`, a `build.sh` to
build & publish the docker image and an example `terraform` directory that will build out an AWS infrastructure that
includes the following resources

- VPC
  - Subnets across Multiple Availability Zones for High Availability
  - Security Groups to control traffic to the Load Balancer
- Application Load Balancer
  - Route 53 DNS Records for the Load Balancer
  - Certificate managed by ACM & attached to the Load Balancer
- ECS Fargate Service & Task for running the webhook server

## Further Reading

In addition to this project we have interactive python tutorials that you can use to learn more about the Sapio REST API
and webhooks on GitHub at [Sapio Python Tutorials](https://github.com/sapiosciences/sapio-py-tutorials/)

## Licenses

sapiocon-24-python are licensed under MPL 2.0.

This license does not provide any rights to use any other copyrighted artifacts from Sapio Sciences. (And they are
typically written in another programming language with no linkages to this library.)

## Getting Help

If you have support contract with Sapio Sciences, please use our technical support channels. support@sapiosciences.com

If you have any questions about how to use sapiopylib, please visit our tutorial page.

If you would like to report an issue on sapiocon-24-python please feel free to create a issue ticket.

## About Us

Sapio is at the forefront of the Digital Lab with its science-aware platform for managing all your life science data
with its integrated Electronic Lab Notebook, LIMS Software and Scientific Data Management System.

Visit us at https://www.sapiosciences.com/
