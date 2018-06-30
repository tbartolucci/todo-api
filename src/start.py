import os, boto3

# def load_ssm_envvars(ssm_path):
#     session = boto3.session.Session()
#
#     client = session.client('ssm')
#     nextToken = ""
#     fullParams = []
#
#     print("Reading parameters from SSM path: {}".format(ssm_path))
#     try:
#         response = client.get_parameters_by_path(
#             Path=ssm_path,
#             Recursive=True,
#             WithDecryption=True
#         )
#         fullParams.extend(response['Parameters'])
#         if 'NextToken' in response:
#             nextToken = response['NextToken']
#     except Exception as e:
#         print("Error querying list of ssm parameters: {}".format(str(e)))
#         raise
#
#     while (nextToken):
#         try:
#             response = client.get_parameters_by_path(
#                 Path=ssm_path,
#                 Recursive=True,
#                 WithDecryption=True,
#                 NextToken=nextToken
#             )
#             fullParams.extend(response['Parameters'])
#             if 'NextToken' in response:
#                 nextToken = response['NextToken']
#             else:
#                 nextToken=""
#         except Exception as e:
#             print("Error querying list of ssm parameters: {}".format(str(e)))
#             raise
#
#     print("Read {} parameters from SSM".format(len(fullParams)))
#
#     for parameter in fullParams:
#         try:
#             envvar_name = parameter['Name'].split('/')[-1]
#             envvar_value = parameter['Value']
#             if envvar_name in os.environ:
#                 print("{} already in environment".format(envvar_name))
#             else:
#                 print("{} - setting value from ssm ({} chars)".format(envvar_name, len(envvar_value)))
#                 os.environ[envvar_name] = envvar_value
#         except Exception as e:
#             print("Error processing parameter: {}".format(str(e)))

print("Starting nginx")
os.system("nginx")

print("Starting application")
os.system("dotnet TodoApi.dll")
