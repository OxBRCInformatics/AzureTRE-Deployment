#!/bin/bash
# shellcheck disable=SC1090

ENV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Default values - you can override these in your environment.env
# -------------------------------------------------------------------------------------------------------
# subscription name passed in from pipeline - if not, use 'local'
if [ -z "$ENVIRONMENT_NAME" ]; then
    export ENVIRONMENT_NAME="local"
fi

echo "Environment set: $ENVIRONMENT_NAME"
echo "Current time: $(date)"

# Pull in variables dependent on the envionment we are deploying to.
if [ -f "$ENV_DIR/environments/$ENVIRONMENT_NAME.env" ]; then
    echo "Loading environment variables for $ENVIRONMENT_NAME"
    . "$ENV_DIR/environments/$ENVIRONMENT_NAME.env"
fi
