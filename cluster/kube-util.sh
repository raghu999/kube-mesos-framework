#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script will source the default skeleton helper functions, then sources
# cluster/${KUBERNETES_PROVIDER}/util.sh where KUBERNETES_PROVIDER, if unset,
# will use its default value (gce).

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/..

source "${KUBE_ROOT}/cluster/skeleton/util.sh"

if [[ -n "${KUBERNETES_CONFORMANCE_TEST:-}" ]]; then
    KUBERNETES_PROVIDER=""
else
    KUBERNETES_PROVIDER="${KUBERNETES_PROVIDER:-mesos/docker}"
fi

PROVIDER_UTILS="${KUBE_ROOT}/cluster/${KUBERNETES_PROVIDER}/util.sh"
if [ -f ${PROVIDER_UTILS} ]; then
    source "${PROVIDER_UTILS}"
fi

# Federation utils

# Should NOT be called within the global scope, unless setting the desired global zone vars
# This function is currently NOT USED in the global scope
function set-federation-zone-vars {
    zone="$1"
    export OVERRIDE_CONTEXT="federation-e2e-${KUBERNETES_PROVIDER}-$zone"
    echo "Setting zone vars to: $OVERRIDE_CONTEXT"
    if [[ "$KUBERNETES_PROVIDER" == "gce"  ]];then

	export KUBE_GCE_ZONE="$zone"
	# gcloud has a 61 character limit, and for firewall rules this
	# prefix gets appended to itself, with some extra information
	# need tot keep it short
	export KUBE_GCE_INSTANCE_PREFIX="${USER}-${zone}"

    elif [[ "$KUBERNETES_PROVIDER" == "gke"  ]];then

	export CLUSTER_NAME="${USER}-${zone}"

    elif [[ "$KUBERNETES_PROVIDER" == "aws"  ]];then

	export KUBE_AWS_ZONE="$zone"
	export KUBE_AWS_INSTANCE_PREFIX="${USER}-${zone}"
    else
	echo "Provider \"${KUBERNETES_PROVIDER}\" is not supported"
	exit 1
    fi
}
