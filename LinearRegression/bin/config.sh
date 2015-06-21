#!/bin/bash

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)

if [ -f "${bin}/../conf/env.sh" ]; then
  set -a
  . "${bin}/../conf/env.sh"
  set +a
fi

#paths
APP=LinearRegression
INPUT_HDFS=${DATA_HDFS}/${APP}/Input
OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output
if [ ${COMPRESS_GLOBAL} -eq 1 ]; then
    INPUT_HDFS=${INPUT_HDFS}-comp
    OUTPUT_HDFS=${OUTPUT_HDFS}-comp
fi

# Either stand alone or yarn cluster
APP_MASTER=${SPARK_MASTER}

set_gendata_opt
set_run_opt

#input benreport
function print_config(){
	local output=$1

	CONFIG=
	if [ ! -z "$SPARK_STORAGE_MEMORYFRACTION" ]; then
	  CONFIG="${CONFIG} memoryFraction ${SPARK_STORAGE_MEMORYFRACTION}"
	fi
	if [ "$MASTER" = "yarn" ]; then
	  if [ ! -z "$SPARK_EXECUTOR_INSTANCES" ]; then
	    CONFIG="${CONFIG} nmem ${SPARK_EXECUTOR_INSTANCES}"
	  fi
	  if [ ! -z "$SPARK_EXECUTOR_CORES" ]; then
	    CONFIG="${CONFIG} exe_core ${SPARK_EXECUTOR_CORES}"
	  fi
	  if [ ! -z "$SPARK_DRIVER_MEMORY" ]; then
	    CONFIG="${CONFIG} dmem ${SPARK_DRIVER_MEMORY}"
	  fi
	fi
	if [ ! -z "$SPARK_EXECUTOR_MEMORY" ]; then
	  CONFIG="${CONFIG} exe_mem ${SPARK_EXECUTOR_MEMORY}"
	fi

	echo "LinearRegressionConfig \
	nexample ${NUM_OF_EXAMPLES} nCluster ${NUM_OF_FEATURES} EPS ${EPS} npar ${NUM_OF_PARTITIONS} Intercepts ${INTERCEPTS} niter ${MAX_ITERATION} \
	${CONFIG}" >> ${output}
}
