//
//  AMJSONResponder.m
//  MusicServer
//
//  Created by Anthony Martin on 30/10/2013.
//  Copyright (c) 2013 Anthony Martin. All rights reserved.
//

#import "AMJSONResponder.h"
#import "AMAPIDataResponder.h"
#import "AMMusicServerActiveData.h"
#import "AMAPIAuthenticationDataResponder.h"

@implementation AMJSONResponder
@synthesize delegate;
@synthesize authDelegate;
@synthesize lastFMDelegate;
@synthesize activeData;

-(id) initWithDelegate:(id<AMAPIDataResponder>)inputDelegate
          authDelegate:(id<AMAPIAuthenticationDataResponder>)inputAuthDelegate
        lastFMDelegate:(AMLastFMCommunicationManager *)inputLastFMDelegate
            activeData:(AMMusicServerActiveData *)data
{
    self = [super init];
    if (self)
    {
        [self setDelegate:inputDelegate];
        [self setAuthDelegate:inputAuthDelegate];
        [self setLastFMDelegate:inputLastFMDelegate];
        [self setActiveData:data];
    }
    return self;
}

-(BOOL) validateSession:(NSString *)Session
{
    return [[self authDelegate] validateSession:Session];
}
 
-(BOOL) handleRequest:(NSData *)data
         responseData:(NSData **)responseData
         responseCode:(NSInteger *)responseCode
        connectedHost:(NSString *)ipAddress
{
    AMJSONAPIData *response = [AMJSONAPIData alloc];
    
    BOOL success = [self handleRequest:data
                              response:&response
                          responseCode:responseCode
                         connectedHost:ipAddress];
    
    if (success)
    {
        *responseData = [response dataFromObject];
        return YES;
    }
    return NO;
}

-(BOOL) handleRequest:(NSData *)data
             response:(AMJSONAPIData **)response
         responseCode:(NSInteger *)responseCode
        connectedHost:(NSString *)ipAddress;
{
    BOOL success = YES;
    NSError *error;
    NSDictionary *dictionary = [AMJSONAPIData deserialiseJSON:data Error:error];
    if (error)
    {
        *responseCode = 500;
        *response = nil;
        return NO;
    }
    
    AMJSONCommandOptions command = [AMJSONAPIData getCommand:dictionary];
    AMJSONAPIData *responseData = nil;
    
    if (command != AMJSONCommandGetSession && command != AMJSONCommandGetToken)
    {
        BOOL validated = NO;
        if ([dictionary objectForKey:@"Session"])
        {
            NSString *session = [dictionary objectForKey:@"Session"];
            validated = ([[self authDelegate] validateSession:session]);
        }
        if (!validated)
        {
            *responseCode = 401;
            *response = nil;
            return NO;
        }
    }
    
    switch (command)
    {
        case AMJSONCommandGetTrackByID:
            if ([[self delegate] respondsToSelector:@selector(getTrackByID:Response:)])
            {
                AMAPIITTrack *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getTrackByID:[request String]
                                               Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetTracks:
            if ([[self delegate] respondsToSelector:@selector(getTracksResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getTracksResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbums:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getAlbumsResponse:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetArtists:
            if ([[self delegate] respondsToSelector:@selector(getArtistsResponse:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataRequest *request = [[AMAPIDataRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getArtistsResponse:&output
                                                        Start:[request Start]
                                                        Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandSearchTracks:
            if ([[self delegate] respondsToSelector:@selector(getTracksBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getTracksBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandSearchAlbums:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsBySearchString:Response:Start:Limit:)])
            {
                
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getAlbumsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandSearchArtists:
            if ([[self delegate] respondsToSelector:@selector(getArtistsBySearchString:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getArtistsBySearchString:[request String]
                                                          Response:&output
                                                             Start:[request Start]
                                                             Limit:[request Limit]];
                responseData = [[AMAPIITArtists alloc] init];
                [(AMAPIITArtists *)responseData setAMAPIITArtistArray:output];
            }
            break;
        case AMJSONCommandGetTracksByArtist:
            if ([[self delegate] respondsToSelector:@selector(getTracksByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getTracksByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetTracksByAlbum:
            if ([[self delegate] respondsToSelector:@selector(getTracksByAlbum:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getTracksByAlbum:[request ID]
                                                   Response:&output
                                                      Start:[request Start]
                                                      Limit:[request Limit]];
                responseData = [[AMAPIITTracks alloc] init];
                [(AMAPIITTracks *)responseData setAMAPIITTrackArray:output];
            }
            break;
        case AMJSONCommandGetAlbumsByArtist:
            if ([[self delegate] respondsToSelector:@selector(getAlbumsByArtist:Response:Start:Limit:)])
            {
                NSArray *output;
                AMAPIDataIDRequest *request = [[AMAPIDataIDRequest alloc] initFromData:data responder:self];
                success = [[self delegate] getAlbumsByArtist:[request ID]
                                                    Response:&output
                                                       Start:[request Start]
                                                       Limit:[request Limit]];
                responseData = [[AMAPIITAlbums alloc] init];
                [(AMAPIITAlbums *)responseData setAMAPIITAlbumArray:output];
            }
            break;
        case AMJSONCommandGetToken:
            if ([[self authDelegate] respondsToSelector:@selector(getToken:response:)])
            {
                AMAPIBlankRequest *request = [[AMAPIBlankRequest alloc] initFromData:data responder:self];
                AMAPIGetTokenResponse *output;
                
                success = [[self authDelegate] getToken:request
                                response:&output];
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetSession:
            if ([[self authDelegate] respondsToSelector:@selector(getSession:response:)])
            {
                AMAPIGetSessionRequest *request = [[AMAPIGetSessionRequest alloc] initFromData:data responder:self];
                AMAPIGetSessionResponse *output;
                
                success = [[self authDelegate] getSession:request
                                                 response:&output];
                
                if (!success) {
                    *responseCode = 401;
                    *response = nil;
                    [[self activeData] auditFailedAuthFromIP:ipAddress];
                    return NO;
                }
                
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandConvertTrackByID:
            if ([[self delegate] respondsToSelector:@selector(convertTrackByID:Response:)])
            {
                AMAPIConvertTrackResponse *output;
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                success = [[self delegate] convertTrackByID:[request String]
                                                   Response:&output];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandLFMScrobbleTrack:
            if ([[self lastFMDelegate] respondsToSelector:@selector(scrobbleTrackByID:)])
            {
                AMAPIScrobbleTrackResponse *output = [[AMAPIScrobbleTrackResponse alloc] init];
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                [[self lastFMDelegate] scrobbleTrackByID:[request String]];
                [output setSuccess:YES];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandLFMNowPlayingTrack:
            if ([[self lastFMDelegate] respondsToSelector:@selector(nowPlayingTrackByID:)])
            {
                AMAPIScrobbleTrackResponse *output = [[AMAPIScrobbleTrackResponse alloc] init];
                AMAPIDataStringRequest *request = [[AMAPIDataStringRequest alloc] initFromData:data responder:self];
                [[self lastFMDelegate] nowPlayingTrackByID:[request String]];
                [output setSuccess:YES];
                responseData = (AMJSONAPIData *)output;
            }
            break;
        case AMJSONCommandGetUserPreferences:
        {
            AMAPIGetUserPreferencesResponse *output = [[AMAPIGetUserPreferencesResponse alloc] init];
            [output setScrobblingEnabled:([[[self activeData] lastFMSessionKey] length] > 0)];
            responseData = (AMJSONAPIData *)output;
            break;
        }
        case AMJSONCommandUnknown:
            success = NO;
            break;
    }
    if (success)
    {
        *responseCode = 200;
        *response = (AMJSONAPIData *)responseData;
    }
    else if (command == AMJSONCommandUnknown)
    {
        *responseCode = 404;
        *response = nil;
    }
    else
    {
        *responseCode = 500;
        *response = nil;
    }
    
    return success;
}

-(void) clearSessions
{
    [[self authDelegate] clearSessions];
}

-(NSInteger) sessionCount
{
    return [[self authDelegate] sessionCount];
}


-(NSString *)secretForSession:(NSString *)Session
{
    return [[self authDelegate] secretForSession:Session];
}

-(void) dealloc
{
    //[[self service] stopService];
}

@end