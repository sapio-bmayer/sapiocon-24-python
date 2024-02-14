from sapiopylib.rest.WebhookService import AbstractWebhookHandler
from sapiopylib.rest.pojo.webhook.WebhookContext import SapioWebhookContext
from sapiopylib.rest.pojo.webhook.WebhookResult import SapioWebhookResult
from sapiopylib.rest.utils.recordmodel.RecordModelManager import RecordModelManager
from sapiopylib.rest.utils.recordmodel.RelationshipPath import RelationshipPath

from webhook.data_type_models import SampleModel, PlateModel


class ActionButtonExample(AbstractWebhookHandler):
    def run(self, context: SapioWebhookContext) -> SapioWebhookResult:
        # Initialize the record model managers.
        rec_man = RecordModelManager(context.user)
        inst_man = rec_man.instance_manager
        rel_man = rec_man.relationship_manager

        # Get the sample from the context and wrap it as a SampleModel.
        sample: SampleModel = inst_man.add_existing_record_of_type(context.data_record, SampleModel)

        # Using the relationship manager, we can load the parent plate of this sample and then the children samples
        # of that plate to get every neighboring sample to the sample we are analyzing.
        rel_man.load_path_of_type([sample], RelationshipPath().parent_type(PlateModel).child_type(SampleModel))
        plate: PlateModel = sample.get_parent_of_type(PlateModel)
        plate_samples: list[SampleModel] = plate.get_children_of_type(SampleModel)

        # Using the instance manager, we can create new records which we can change and relate to other records,
        # all without making any webservice requests.
        results: SampleModel = inst_man.add_new_record_of_type(SampleModel)
        sample.add_child(results)

        # This endpoint could then call an endpoint elsewhere that runs analysis on the gathered information.
        self.run_analysis_api(sample, plate, plate_samples, results)

        # Commit any record model changes that were made by this webhook, from field updates to relationship changes to
        # the creation of new records entirely.
        rec_man.store_and_commit()
        return SapioWebhookResult(True)

    @staticmethod
    def run_analysis_api(sample, plate, plate_samples, results):
        # Imagine this function built a payload and sent it to an endpoint on another system.
        # response = requests.post(url="https://FancyAnalysis.com/sample", json={"Sample": sample,
        #                                                                        "Plate": plate,
        #                                                                        "Plate Samples": plate_samples,
        #                                                                        "Results": results})
        sample.set_ExemplarSampleStatus_field("Analyzed :)")
