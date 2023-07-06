import base64
import json
from httplib2 import Http
from dateutil.parser import isoparse
from datetime import datetime, timezone
import pytz
import os

GGCHAT_URL = os.environ.get('GGCHAT_URL', 'Environment variable does not exist')

#################### CLOUDDEPLOY RESOURCES #################### 
def clouddeploy_resources(event, context):
    payload = event['attributes']
    print(payload)
    message =  """{{ "cards": [{{
        "header": {{
            "title": "Cloud Deploy Notification for Delivery Pipeline",
            "subtitle": "Action {action} on {resource_type}"
        }},
        "sections": [{{
            "widgets": [
                {{"keyValue": {{"topLabel": "DeliveryPipeline", "content": "{delivery_pipeline}"}} }},
                {{"keyValue": {{"topLabel": "Region", "content": "{region}"}} }}
            ]
        }} ]
    }} ] }} """.format(
                    action=payload['Action'],
                    resource_type=payload['ResourceType'],
                    delivery_pipeline=payload['DeliveryPipelineId'],
                    region=payload['Location']
                    )

    message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

    http_obj = Http()
    response = http_obj.request(
        uri=GGCHAT_URL,
        method='POST',
        headers=message_headers,
        body=json.dumps(json.loads(message))
    )
    print(response)


#################### CLOUDDEPLOY OPERATIONS #################### 
def clouddeploy_operations(event, context):
    payload = event['attributes']
    print(payload)
    message =  """{{ "cards": [{{
        "header": {{
            "title": "Cloud Deploy Notification for Deployment Operation",
            "subtitle": "Action {action} on {resource_type}"
        }},
        "sections": [{{
            "widgets": [
                {{"keyValue": {{"topLabel": "DeliveryPipeline", "content": "{delivery_pipeline}"}} }},
                {{"keyValue": {{"topLabel": "Region", "content": "{region}"}} }},
                {{"keyValue": {{"topLabel": "ReleaseId", "content": "{releaseId}"}} }},
                {{"buttons": [{{
                    "textButton": {{
                        "text": "Log Link",
                        "onClick": {{"openLink": {{"url": "{log_url}"}} }}
                    }} 
                }} ] }}
            ]
        }} ]
    }} ] }} """.format(
                    action=payload['Action'],
                    resource_type=payload['ResourceType'],
                    delivery_pipeline=payload['DeliveryPipelineId'],
                    region=payload['Location'],
                    releaseId=payload['ReleaseId'],
                    log_url="https://www.google.com"
                    )

    message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

    http_obj = Http()
    response = http_obj.request(
        uri=GGCHAT_URL,
        method='POST',
        headers=message_headers,
        body=json.dumps(json.loads(message))
    )
    print(response)

#################### CLOUDDEPLOY APPROVALS #################### 
def clouddeploy_approvals(event, context):
    payload = event['attributes']
    print(payload)
    message =  """{{ "cards": [{{
        "header": {{
            "title": "Cloud Deploy Notification for Delivery Pipeline",
            "subtitle": "Action {action} on {resource_type}"
        }},
        "sections": [{{
            "widgets": [
                {{"keyValue": {{"topLabel": "DeliveryPipeline", "content": "{delivery_pipeline}"}} }},
                {{"keyValue": {{"topLabel": "Region", "content": "{region}"}} }}
            ]
        }} ]
    }} ] }} """.format(
                    action=payload['Action'],
                    resource_type=payload['ResourceType'],
                    delivery_pipeline=payload['DeliveryPipelineId'],
                    region=payload['Location']
                    )

    message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

    http_obj = Http()
    response = http_obj.request(
        uri=GGCHAT_URL,
        method='POST',
        headers=message_headers,
        body=json.dumps(json.loads(message))
    )
    print(response)

#################### CLOUDDEPLOY ADVANCES #################### 
def clouddeploy_advances(event, context):
    payload = event['attributes']
    print(payload)
    message =  """{{ "cards": [{{
        "header": {{
            "title": "Cloud Deploy Notification for Delivery Pipeline",
            "subtitle": "Action {action} on {resource_type}"
        }},
        "sections": [{{
            "widgets": [
                {{"keyValue": {{"topLabel": "DeliveryPipeline", "content": "{delivery_pipeline}"}} }},
                {{"keyValue": {{"topLabel": "Region", "content": "{region}"}} }}
            ]
        }} ]
    }} ] }} """.format(
                    action=payload['Action'],
                    resource_type=payload['ResourceType'],
                    delivery_pipeline=payload['DeliveryPipelineId'],
                    region=payload['Location']
                    )

    message_headers = {'Content-Type': 'application/json; charset=UTF-8'}

    http_obj = Http()
    response = http_obj.request(
        uri=GGCHAT_URL,
        method='POST',
        headers=message_headers,
        body=json.dumps(json.loads(message))
    )
    print(response)