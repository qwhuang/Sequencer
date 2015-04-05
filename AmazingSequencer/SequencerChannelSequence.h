//
//  SequencerChannelSequence.h
//  AmazingSequencer
//
//  Created by Ariel Elkin on 03/03/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SequencerBeat.h"

@interface SequencerChannelSequence : NSObject


/*!
 * Adds a beat to the sequence.
 *
 * Beats are automatically sorted by their onsets, in
 * ascending order.
 *
 */
- (void)addBeat:(SequencerBeat *)beat;


/*!
 * Removes a beat from the sequence.
 *
 * Returns nil if sequence does not contain a beat
 * with specified onset.
 *
 */
- (void)removeBeatAtOnset:(float)onset;


/*!
 * Sets the onset of a beat located at a specified onset
 * in the sequence.
 *
 */
- (void)setOnsetOfBeatAtOnset:(float)oldOnset to:(float)newOnset;


/*!
 * Sets the velocity of a beat located at a specified onset
 * of the sequence.
 *
 */
- (void)setVelocityOfBeatAtOnset:(float)onset to:(float)newVelocity;


/*!
 * Returns the beat with the specified onset in the sequence.
 *
 */
- (SequencerBeat *)beatAtOnset:(float)onset;


/* 
 * Returns an array with all the beats in the sequence.
 *
 */
- (NSArray *)allBeats;


/*!
 * Returns the number of beats present in the sequence.
 *
 */
@property (nonatomic, readonly) NSUInteger count;


/*!
 * Returns a C representation of the sequence as an
 * array of BEAT.
 *
 */
@property (readonly) BEAT *sequenceCRepresentation;

@end
