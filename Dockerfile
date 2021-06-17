FROM dkrutskikh/dart_code_metrics_action:v1

ENTRYPOINT ["dart", "run", "/action_app/bin/main.dart"]
