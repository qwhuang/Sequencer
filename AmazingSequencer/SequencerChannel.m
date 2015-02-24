//
//  MyChannel.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 25/06/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "SequencerChannel.h"
#import "AEAudioFileLoaderOperation.h"

#import <mach/mach_time.h>

static double __secondsPerHostTick = 0.0;
static double __hostTicksPerSecond = 0.0;
static double __hostTicksPerFrame = 0.0;
static uint64_t kSampleRate;

@implementation SequencerChannel {
    AudioBufferList *audioSampleBufferList;
    UInt32 lengthInFrames;
}

+ (instancetype)sequencerChannelWithAudioFileAt:(NSURL *)url audioController:(AEAudioController*)audioController repeatAtBPM:(UInt64)bpm {

    SequencerChannel *channel = [[self alloc] init];

    //Load audio file:
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url targetAudioDescription:audioController.audioDescription];
    [operation start];
    if ( operation.error ) {
        NSLog(@"load error: %@", operation.error);
        return nil;
    }

    channel->audioSampleBufferList = operation.bufferList;
    channel->lengthInFrames = operation.lengthInFrames;


    //Set the interval at which we'll play the file.
    //In this case, every second (i.e. at 60 BPM)

    kSampleRate = (uint64_t)audioController.audioDescription.mSampleRate;
    mach_timebase_info_data_t tinfo;
    mach_timebase_info(&tinfo);
    __secondsPerHostTick = ((double)tinfo.numer / tinfo.denom) * 1.0e-9;
    __hostTicksPerSecond = 1.0 / __secondsPerHostTick;
    __hostTicksPerFrame = __hostTicksPerSecond / kSampleRate;

    return channel;
}

static OSStatus renderCallback(__unsafe_unretained SequencerChannel *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 frames,
                               AudioBufferList *audio) {

    static UInt64 _playbackStartTime;
    if ( !_playbackStartTime ) {
        _playbackStartTime = inTimeStamp->mHostTime;
    }

    //Figure out where we are in time:
    uint64_t bufferStartPlaybackPosition = inTimeStamp->mHostTime - _playbackStartTime;
    uint64_t bufferEndPlaybackPosition = bufferStartPlaybackPosition + (frames * __hostTicksPerFrame);

    static UInt32 playHead;

    //If it's time for the audio to start playing, set the playhead to 0
    //so that the buffers are being filled at the start:
    if ( bufferEndPlaybackPosition % (uint64_t)__hostTicksPerSecond < bufferStartPlaybackPosition % (uint64_t)__hostTicksPerSecond ) {
        playHead = 0;
    }

    //Fill buffers with audio if we are supposed to be
    //playing audio, don't  otherwise:
    for ( int i=0; i<frames; i++ ) {
        for ( int j=0; j<audio->mNumberBuffers; j++ ) {

            if (playHead < THIS->lengthInFrames) {
                ((float *)audio->mBuffers[j].mData)[i] = ((float *)THIS->audioSampleBufferList->mBuffers[j].mData)[playHead + i];
            }
            else {
                ((float *)audio->mBuffers[j].mData)[i] = 0;
            }
        }
    }

    playHead += frames;

    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback {
    return &renderCallback;
}


#pragma mark -
#pragma mark TODO

- (void) stopPlayback {
}


- (void) repeatAtBPM:(UInt64)newBPM {
}


@end