from truefoundry.deploy import trigger_job

response = trigger_job(
    application_fqn="tfy-prod-euwe1:analytics-server:inframold-vulnerability-scanner",
    params={"inframold_chart_name": "_all"},
)

print(response.jobRunName)
