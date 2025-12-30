#!/bin/sh

DMC_PATH1=/sys/class/devfreq/dmc
DMC_PATH2=/sys/bus/platform/drivers/rockchip-dmc/dmc/devfreq/dmc

if [ -d "$DMC_PATH1" ];then
    DMC_PATH=$DMC_PATH1
elif [ -d $DMC_PATH2 ];then
    DMC_PATH=$DMC_PATH2
else
    echo "Invalid DMC path, please check if DMC is enabled"
    exit
fi

echo "DMC Path:" $DMC_PATH

# Display usage
usage() {
    echo "Usage:"
    echo "  $0            - Cycle frequency without sleep"
    echo "  $0 [interval] - Cycle frequency with specified interval"
    echo ""
    echo "Examples:"
    echo "  $0     - Cycle frequency without sleep"
    echo "  $0 0.1 - Change frequency every 0.1 seconds"
}

# Frequency cycling function
do_freq_scaling() {
    sleep_interval=$1

    # Display sleep status
    if [ -n "$sleep_interval" ]; then
        echo "Running frequency cycling with ${sleep_interval}s interval"
    else
        echo "Running frequency cycling without sleep"
    fi

    while true; do
        echo userspace > $DMC_PATH/governor

        # Get frequency count and select random index
        count=$(cat $DMC_PATH/available_frequencies | wc | awk '{print $2}')
        j=$(( RANDOM % count + 1 ))

        # Get the frequency at selected index
        FREQ=$(cat $DMC_PATH/available_frequencies | awk -v val=$j '{print $val}')

        # Set frequency
        echo ${FREQ} > $DMC_PATH/userspace/set_freq

        # Print current frequency
        cur_freq=$(cat $DMC_PATH/cur_freq)
        echo "Current frequency: ${cur_freq}Hz"

        # Sleep if interval specified
        if [ -n "$sleep_interval" ]; then
            sleep $sleep_interval
        fi
    done
}

# If no parameters, run frequency cycling without sleep
if [ "$#" -eq "0" ]; then
    do_freq_scaling
# If one parameter
elif [ "$#" -eq "1" ]; then
    # Treat all parameters as interval time
    do_freq_scaling "$1"
else
    # Too many parameters, show usage
    usage
fi
