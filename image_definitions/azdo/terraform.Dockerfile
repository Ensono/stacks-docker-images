# NAME dnitsch/cicd-utils-azdo-tf
FROM hashicorp/terraform:1.3.1 AS tf-bin
# 
FROM dnitsch/cicd-utils-azdo-awscliv2:0.0.4

COPY --from=tf-bin /bin/terraform /bin/terraform

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

CMD [ "node" ]

# TFS says not to add entrypoint
# however it seems to only work with
# this entrypoint set
ENTRYPOINT [ "/usr/bin/env" ]