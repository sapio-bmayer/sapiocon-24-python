from sapiopylib.rest.WebhookService import AbstractWebhookHandler
from sapiopylib.rest.pojo.eln.ElnExperiment import InitializeNotebookExperimentPojo, ElnTemplate, \
    TemplateExperimentQueryPojo, ElnExperiment
from sapiopylib.rest.pojo.eln.ExperimentEntry import ExperimentEntry
from sapiopylib.rest.pojo.webhook.WebhookContext import SapioWebhookContext
from sapiopylib.rest.pojo.webhook.WebhookDirective import ElnExperimentDirective
from sapiopylib.rest.pojo.webhook.WebhookResult import SapioWebhookResult
from sapiopylib.rest.utils.Protocols import ElnExperimentProtocol, ElnEntryStep


class TableToolbarExample(AbstractWebhookHandler):
    def run(self, context: SapioWebhookContext) -> SapioWebhookResult:
        # Create the experiment lke we did in the MainToolbarExample.
        experiment: ElnExperiment = self.create_experiment(context)
        # This time we want to manipulate the experiment's contents.
        # Convert the experiment into a protocol object, which provide methods for easily working with experiments.
        protocol = ElnExperimentProtocol(experiment, context.user)
        # Get the entries (steps) of the experiment (protocol), sorting them into a dict for easy access.
        entries: dict[str, ElnEntryStep] = {x.get_name(): x for x in protocol.get_sorted_step_list()}

        # Add the records from the context, which are the records we selected in the table, to the
        # samples step. This means that the samples entry will already be populated when we get to it.
        samples_entry: ElnEntryStep = entries.get("Samples")
        samples_entry.set_records(context.data_record_list)
        samples_entry.complete_step()

        # Once again direct the user to the experiment.
        return SapioWebhookResult(True, directive=ElnExperimentDirective(protocol.get_id()))

    @staticmethod
    def create_experiment(context: SapioWebhookContext) -> ElnExperiment:
        template_name: str = "SapioCon 2024 Template"

        template_query = TemplateExperimentQueryPojo(latest_version_only=True, active_templates_only=True)
        templates: list[ElnTemplate] = context.eln_manager.get_template_experiment_list(template_query)

        launch_template: ElnTemplate | None = None
        for template in templates:
            if template.template_name == template_name:
                launch_template = template
                break

        notebook_init = InitializeNotebookExperimentPojo(launch_template.display_name, launch_template.template_id)
        return context.eln_manager.create_notebook_experiment(notebook_init)