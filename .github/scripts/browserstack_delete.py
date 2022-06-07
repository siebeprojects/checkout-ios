import requests
import urllib.parse
import sys
import os

session = requests.Session()


def main():
    try:
        session.auth = (os.getenv('BROWSERSTACK_USER'),
                        os.getenv('BROWSERSTACK_KEY'))

        # First argument from command line is custom_id for Browserstack
        if len(sys.argv) < 2:
            sys.exit(f'::error::Please provide a custom id')
        custom_id = sys.argv[1]

        delete_recent_apps(custom_id)

    except Exception as error:
        sys.exit(f'::error::{error}')


def delete_recent_apps(custom_id: str):
    print(f'Deleting binaries with custom_id {custom_id}')

    recent_uploads = get_recent_uploads(custom_id)
    if isinstance(recent_uploads, dict) and recent_uploads["message"] is not None:
        if recent_uploads["message"] == "No results found":
            print("Nothing to delete")
            return
        else:
            raise Exception(recent_uploads["message"])

    for app in recent_uploads:
        if not isinstance(app, dict):
            print(f'::warning::Unexpected response from Browserstack: {app}')
            continue

        delete(app)


def get_recent_uploads(custom_id: str):
    """Get recent uploads from Browserstack"""

    recent_apps_url = urllib.parse.urljoin(
        'https://api-cloud.browserstack.com/app-live/recent_apps/', custom_id)
    recent_uploads = session.get(recent_apps_url)
    recent_uploads.raise_for_status()
    return recent_uploads.json()


def delete(app: dict):
    """Delete an application from Browserstack live

        Parameters:
        app: application json object from Browserstack recent_apps call
    """

    app_id = app['app_id']
    app_name = app['app_name']
    delete_url = urllib.parse.urljoin(
        'https://api-cloud.browserstack.com/app-live/app/delete/', app_id)
    print(f'* Deleting {app_name}…')

    deletion_result = session.delete(delete_url)
    deletion_result.raise_for_status()


if __name__ == "__main__":
    main()
