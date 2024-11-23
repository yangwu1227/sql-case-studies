from typing import Optional

import boto3
from botocore.exceptions import NoCredentialsError, NoRegionError


def create_session(
    profile_name: str,
    role_arn: Optional[str] = None,
    duration_seconds: Optional[int] = 3600,
) -> boto3.Session:
    """
    Create a boto3 session with the provided profile name. If an AWS role ARN is provided, the session will assume the role. There are two options for providing
    credentials:

    1. Provide the profile name containing AWS credentials stored in the ~/.aws/credentials file
       (e.g., access key ID, secret access key, or session token). These credentials must belong
       to a principal (e.g., an IAM user) that has the necessary permissions to interact with the
       AWS services required by the application.

    2. Provide the AWS role ARN, in addition to the profile name, to assume, which grants the necessary
       permissions to interact with AWS services. If a role ARN is provided, the profile's associated
       principal (e.g., an IAM user) must at least have the `sts:AssumeRole` permission. Additionally,
       the role to be assumed must have a trust relationship with the principal that uses the profile's
       credentials.

    Parameters
    ----------
    profile_name: str
        The AWS profile name to use.
    role_arn: Optional[str]
        The AWS role ARN to assume. The default is None.
    duration_seconds: Optional[int]
        The duration in seconds for which the credentials will be valid. The default is 3600 seconds (1 hour).

    Returns
    -------
    boto3.Session
        A boto3 session

    Examples
    --------
    >>> from utils import create_session
    >>> boto3_session = create_session(profile_name='my-profile', role_arn='arn:aws:iam::123456789012:role/my-role')
    """
    try:
        session = boto3.Session(profile_name=profile_name)
        region_name = session.region_name
        if not region_name:
            raise NoRegionError

        if role_arn:
            sts_client = session.client("sts", region_name=region_name)
            # Assume role for 12 hours
            response = sts_client.assume_role(
                RoleArn=role_arn,
                RoleSessionName="AssumeRoleSession",
                DurationSeconds=duration_seconds,
            )
            return boto3.Session(
                aws_access_key_id=response["Credentials"]["AccessKeyId"],
                aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
                aws_session_token=response["Credentials"]["SessionToken"],
                region_name=region_name,
            )
        return session

    except NoRegionError:
        print(
            "Region not specified in the profile; please checkt the configuration e.g., ~/.aws/config"
        )
    except NoCredentialsError:
        print(
            "Credentials not foundl please check the credentials file e.g., ~/.aws/credentials"
        )
    except Exception as e:
        print(f"An error occurred: {e}")

    return None
