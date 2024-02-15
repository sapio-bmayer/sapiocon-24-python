from typing import Any
from sapiopylib.rest.User import SapioUser
from sapiopylib.rest.DataMgmtService import DataMgmtServer


# The following are the connection details for the Sapio REST API.
# This is typically loaded from a file or environment variables

# The URL of the platform webservice api. Typically, ends with /webservice/api
app_url = 'https://acme-corp.exemplareln.com/webservice/api'

# The guid of the app to connect to.
# This isn't required if running in SaaS, only when local or if multiple apps are on the domain.
# When we host we use subdomains to uniquely identify each app, so this isn't needed.
app_guid = None #Example value: 'a74a73ca-287f-44b2-8cd3-448690430caf'


# The username of the connection. (skip if api_key provided)
api_username = 'sapiocon24_api'
# The password of the connection. (skip if api_key provided)
api_password = 'ooRrmddCdE2e4nf'


# The API key of the connection. (skip if username/password provided.)
api_key = None #Example Value: 'ooRrmddCdE2e4nf'


if __name__ == "__main__":
    if api_username and api_password:
        user: SapioUser = SapioUser(url=app_url, guid=app_guid,
                                    username=api_username, password=api_password)
    else:
        user: SapioUser = SapioUser(url=app_url, guid=app_guid,
                                    api_token=api_key)
    dataRecordManager = DataMgmtServer.get_data_record_manager(user)
    report_man = DataMgmtServer.get_custom_report_manager(user)
    report: list[list[Any]] = report_man.run_system_report_by_name("Unassigned Samples").result_table

    print(f"Found {len(report)} unassigned samples.")