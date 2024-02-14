from sapiopylib.rest.WebhookService import AbstractWebhookHandler
from sapiopylib.rest.pojo.eln.ElnExperiment import InitializeNotebookExperimentPojo, ElnTemplate, \
    TemplateExperimentQueryPojo
from sapiopylib.rest.pojo.webhook.WebhookContext import SapioWebhookContext
from sapiopylib.rest.pojo.webhook.WebhookDirective import ElnExperimentDirective
from sapiopylib.rest.pojo.webhook.WebhookResult import SapioWebhookResult


class MainToolbarExample(AbstractWebhookHandler):
    def run(self, context: SapioWebhookContext) -> SapioWebhookResult:
        # This button will send the user to a new experiment with this template name.
        template_name: str = "SapioCon 2024 Template"

        # First we must get all the templates in the system.
        template_query = TemplateExperimentQueryPojo(latest_version_only=True, active_templates_only=True)
        templates: list[ElnTemplate] = context.eln_manager.get_template_experiment_list(template_query)

        # Then filter the list of all templates to find the one we want.
        launch_template: ElnTemplate = [x for x in templates if x.template_name == template_name][0]

        # With that, we can use the ElnManager to create a new experiment.
        notebook_init = InitializeNotebookExperimentPojo(launch_template.display_name, launch_template.template_id)
        experiment = context.eln_manager.create_notebook_experiment(notebook_init)
        # Returning a result with an ElnExperimentDirective will send the user to the given experiment.
        return SapioWebhookResult(True, directive=ElnExperimentDirective(experiment.notebook_experiment_id))
