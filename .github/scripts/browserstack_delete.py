import requests
import urllib.parse
import sys
import os

# Browserstack API: https://www.browserstack.com/app-live/rest-api

session = requests.Session()


def main():
    try:
        session.auth = (os.getenv('BROWSERSTACK_USER'),
                        os.getenv('BROWSERSTACK_KEY'))

        # First argument from command line is custom_id for Browserstack
        custom_id = sys.argv[1]
        recent_uploads = get_recent_uploads(custom_id)

        for app in recent_uploads:
            delete(app)

    except Exception as error:
        sys.exit(f'::error::{error}')


def get_recent_uploads(custom_id):
    """Get recent uploads from Browserstack"""

    recent_apps_url = urllib.parse.urljoin(
        'https://api-cloud.browserstack.com/app-live/recent_apps/', custom_id)
    recent_uploads = session.get(recent_apps_url)
    recent_uploads.raise_for_status()
    return recent_uploads.json()


def delete(app):
    """Delete an application from Browserstack live

        Parameters:
        app: application json object from Browserstack recent_apps call
    """

    if not isinstance(app, dict):
        return

    app_id = app['app_id']
    app_name = app['app_name']
    delete_url = urllib.parse.urljoin(
        'https://api-cloud.browserstack.com/app-live/app/delet/', app_id)
    print(f'* Deleting {app_name}…')

    deletion_result = session.delete(delete_url)
    deletion_result.raise_for_status()


if __name__ == "__main__":
    main()
