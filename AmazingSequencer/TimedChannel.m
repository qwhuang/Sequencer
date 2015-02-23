//
//  TimedChannel.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 23/02/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "TimedChannel.h"
#import <mach/mach_time.h>

static mach_timebase_info_data_t sTimebaseInfo;

@implementation TimedChannel

+ (instancetype)repeatAtTime:(float)time {

    TimedChannel *channel = [[self alloc] init];

    //sTimebaseInfo stores how many ticks we have per nanosecond.
    //ticks per nanosecond equal (sTimebaseInfo.numer / sTimebaseInfo.denom)
    if ( sTimebaseInfo.denom == 0 ) {
        mach_timebase_info(&sTimebaseInfo);
    }

    return channel;
}

static void timingCallback (__unsafe_unretained id    receiver,
                            __unsafe_unretained AEAudioController *audioController,
                            const AudioTimeStamp     *time,
                            UInt32                    frames,
                            AEAudioTimingContext      context) {


    UInt64 currentTimeInTicks = time->mHostTime;

    double currentTimeInNanoSeconds = currentTimeInTicks * (sTimebaseInfo.numer / sTimebaseInfo.denom);

    double currentTimeInSeconds = currentTimeInNanoSeconds / 1000000000;

    printf("%f\n", currentTimeInSeconds);

}


-(AEAudioControllerTimingCallback)timingReceiverCallback {
    return &timingCallback;
}

@end
