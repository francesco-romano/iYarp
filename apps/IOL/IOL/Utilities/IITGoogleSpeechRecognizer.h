//
//  IITGoogleSpeechRecognizer.h
//  IOL
//
//  Created by Francesco Romano on 19/06/16.
//  Copyright © 2016 Istituto Italiano di Tecnologia. All rights reserved.
//

#import "IITSpeechRecognizer+ClusterUtilities.h"

@interface IITGoogleSpeechRecognizer : IITSpeechRecognizer
@property (nonatomic, strong) NSString *apiKey;
@end
