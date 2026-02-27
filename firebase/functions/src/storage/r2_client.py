"""
Cloudflare R2 client for generating presigned URLs.

Uses boto3 S3-compatible API to interact with Cloudflare R2.
Credentials are read from environment variables (set via GCP Secret Manager
or firebase functions:config:set).
"""

import os
import boto3
from botocore.config import Config


class R2Client:
    """Cloudflare R2 storage client using S3-compatible presigned URLs."""

    def __init__(self):
        account_id = os.environ.get("R2_ACCOUNT_ID")
        access_key = os.environ.get("R2_ACCESS_KEY_ID")
        secret_key = os.environ.get("R2_SECRET_ACCESS_KEY")
        self.bucket_name = os.environ.get("R2_BUCKET_NAME", "pet-companion-bucket")

        if not all([account_id, access_key, secret_key]):
            raise ValueError(
                "R2 credentials not configured. Set R2_ACCOUNT_ID, "
                "R2_ACCESS_KEY_ID, and R2_SECRET_ACCESS_KEY environment variables."
            )

        self._client = boto3.client(
            "s3",
            endpoint_url=f"https://{account_id}.r2.cloudflarestorage.com",
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name="auto",
            config=Config(signature_version="s3v4"),
        )

    def generate_upload_url(
        self,
        key: str,
        content_type: str = "image/jpeg",
        expires_in: int = 3600,
    ) -> str:
        """Generate a presigned URL for uploading an object to R2.

        Args:
            key: Object key (path within the bucket).
            content_type: MIME type of the object.
            expires_in: URL validity in seconds (default: 1 hour).

        Returns:
            Presigned PUT URL.
        """
        return self._client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": self.bucket_name,
                "Key": key,
                "ContentType": content_type,
            },
            ExpiresIn=expires_in,
        )

    def generate_download_url(
        self,
        key: str,
        expires_in: int = 3600,
    ) -> str:
        """Generate a presigned URL for downloading an object from R2.

        Args:
            key: Object key (path within the bucket).
            expires_in: URL validity in seconds (default: 1 hour).

        Returns:
            Presigned GET URL.
        """
        return self._client.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": self.bucket_name,
                "Key": key,
            },
            ExpiresIn=expires_in,
        )
