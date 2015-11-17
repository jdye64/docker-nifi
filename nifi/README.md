Organize everything under `nifi` directory, this way Docker Compose will have nice predicable node names like `nifi_acquisitiion_1`
without any additional effor on the user side.

This is a workaround until https://github.com/docker/compose/issues/2312 is implemented.
