import os

from sapiopylib.rest.WebhookService import WebhookConfiguration, WebhookServerFactory

from webhook.twenty_four.ELNRuleExample import ELNRuleExample
from webhook.twenty_four.MainToolbarExample import MainToolbarExample
from webhook.twenty_four.TableToolbarExample import TableToolbarExample
from webhook.twenty_three.action_button import DemoActionButtonHandler
from webhook.twenty_three.custom_report import CustomReportExampleHandler
from webhook.twenty_three.list_technicians import GetAvailableTechnicians
from webhook.twenty_three.hello_world import HelloWorldWebhookHandler
from webhook.twenty_three.list_homeworlds import GetHomeWorldList
from webhook.twenty_three.load_instrument_data import LoadInstrumentDataHandler
from webhook.twenty_three.record_model import RecordModelExampleHandler
from waitress import serve


# Create the Sapio webhook configuration that will handle the processing of
config: WebhookConfiguration = WebhookConfiguration(verify_sapio_cert=True, debug=False)


if os.environ.get('SapioWebhooksInsecure') == "True":
    config.verify_sapio_cert = False

config.register('/2023/hello_world', HelloWorldWebhookHandler)
config.register('/2023/load_inst_data', LoadInstrumentDataHandler)
config.register('/2023/available_technicians', GetAvailableTechnicians)
config.register('/2023/home_worlds', GetHomeWorldList)
config.register('/2023/action_button', DemoActionButtonHandler)
config.register('/2023/record_model', RecordModelExampleHandler)
config.register('/2023/custom_report', CustomReportExampleHandler)
config.register('/24/eln-rule-example', ELNRuleExample)
config.register('/24/main-toolbar-example', MainToolbarExample)
config.register('/24/table-toolbar-example', TableToolbarExample)


# Create a flask application with the Sapio Webhook configuration
app = WebhookServerFactory.configure_flask_app(app=None, config=config)


# Return the README.md file as a html file for the homepage of the webhook
@app.route('/')
def http_root():
    import markdown
    readme_file = open('README.md')
    output = """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<style type="text/css">
"""
    output += open('doc/avenir-white.css').read()
    output += "</style></head><body>"
    output += markdown.markdown(readme_file.read())
    output += "</body></html>"
    return output


# This method is a health check for render.com to use to know when the python process is alive and is healthy
@app.route('/health_check')
def health_check():
    return 'Alive'


if __name__ == "__main__":
    # UNENCRYPTED! This should not be used in production. You should give the "app" a ssl_context or set up a reverse-proxy.
    if os.environ.get('SapioWebhooksDebug') == "True":
        app.run(host="0.0.0.0", port=8080, debug=True)
    else:
        serve(app, host="0.0.0.0", port=8080)

