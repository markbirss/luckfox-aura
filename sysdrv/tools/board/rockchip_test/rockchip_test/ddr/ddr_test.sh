#!/bin/sh

CURRENT_DIR=`dirname $0`

info_view()
{
	echo "*****************************************************"
	echo "***                                               ***"
	echo "***            DDR TEST                           ***"
	echo "***                                               ***"
	echo "*****************************************************"
}

info_view
echo "*****************************************************"
echo "memtester test:                                 1"
echo "stressapptest:                                  2"
echo "ddr dmc test:                                   3"
echo "*****************************************************"

read -t 30 DDR_CHOICE

memtester_test()
{
	sh ${CURRENT_DIR}/memtester_test.sh
}

stressapptest_test()
{
	sh ${CURRENT_DIR}/stressapptest_test.sh
}

ddr_dmc_test()
{
	sh ${CURRENT_DIR}/ddr_freq_scaling.sh &
}

case ${DDR_CHOICE} in
	1)
		memtester_test
		;;
	2)
		stressapptest_test
		;;
	3)
		ddr_dmc_test
		;;
	*)
		echo "not fount your input."
		;;
esac
