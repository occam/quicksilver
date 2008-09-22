//
// QSense.m
// QSqSense
//
// Created by Alcor on 11/22/04.
// Copyright 2004 Blacktree. All rights reserved.
//

#import "QSense.h"

#define MIN_ABBR_OPTIMIZE 0
#define IGNORED_SCORE 0.9
#define SKIPPED_SCORE 0.15

float QSScoreForAbbreviationWithRanges(CFStringRef str, CFStringRef abbr, id mask, CFRange strRange, CFRange abbrRange);

float QSScoreForAbbreviation(CFStringRef str, CFStringRef abbr, id mask) {
	return QSScoreForAbbreviationWithRanges(str, abbr, mask, CFRangeMake(0, CFStringGetLength(str) ), CFRangeMake(0, CFStringGetLength(abbr)));
}

float QSScoreForAbbreviationWithRanges(CFStringRef str, CFStringRef abbr, id mask, CFRange strRange, CFRange abbrRange) {
	float score, remainingScore;
	int i, j;
	CFRange matchedRange, remainingStrRange, adjustedStrRange = strRange;
    CFLocaleRef userLoc = CFLocaleCopyCurrent();
	if (!abbrRange.length) return IGNORED_SCORE; //deduct some points for all remaining letters
	if (abbrRange.length>strRange.length) return 0.0;
    if (!CFStringFindWithOptionsAndLocale(str, abbr,
                                          strRange,
                                          kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareLocalized,
                                          userLoc, &matchedRange)) {
        CFRelease(userLoc);
        return 0.0;
    }

	for (i = abbrRange.length; i > 0; i--) { //Search for steadily smaller portions of the abbreviation
		CFStringRef curAbbr = CFStringCreateWithSubstring (NULL, abbr, CFRangeMake(abbrRange.location, i) );
		//terminality
		//axeen
		BOOL found = CFStringFindWithOptionsAndLocale(str, curAbbr,
                                                      CFRangeMake(adjustedStrRange.location, adjustedStrRange.length - abbrRange.length + i),
                                                      kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareLocalized,
                                                      userLoc, &matchedRange);
		CFRelease(curAbbr);

		if (!found) continue;

		if (mask) [mask addIndexesInRange:NSMakeRange(matchedRange.location, matchedRange.length)];

		remainingStrRange.location = matchedRange.location+matchedRange.length;
		remainingStrRange.length = strRange.location+strRange.length-remainingStrRange.location;

		// Search what is left of the string with the rest of the abbreviation
		remainingScore = QSScoreForAbbreviationWithRanges(str, abbr, mask, remainingStrRange, CFRangeMake(abbrRange.location+i, abbrRange.length-i) );

		if (remainingScore) {
			score = remainingStrRange.location-strRange.location;
			// ignore skipped characters if is first letter of a word
			if (matchedRange.location>strRange.location) {//if some letters were skipped
				static CFCharacterSetRef whitespace = NULL;
				if (!whitespace) whitespace = CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
				static CFCharacterSetRef uppercase = NULL;
				if (!uppercase) uppercase = CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
				j = 0;
				if (CFCharacterSetIsCharacterMember(whitespace, CFStringGetCharacterAtIndex(str, matchedRange.location-1) )) {
					for (j = matchedRange.location-2; j >= (int) strRange.location; j--) {
						if (CFCharacterSetIsCharacterMember(whitespace, CFStringGetCharacterAtIndex(str, j) )) score--;
						else score -= SKIPPED_SCORE;
					}
				} else if (CFCharacterSetIsCharacterMember(uppercase, CFStringGetCharacterAtIndex(str, matchedRange.location) )) {
					for (j = matchedRange.location-1; j >= (int) strRange.location; j--) {
						if (CFCharacterSetIsCharacterMember(uppercase, CFStringGetCharacterAtIndex(str, j) ))
							score--;
						else
							score -= SKIPPED_SCORE;
					}
				} else {
					score -= matchedRange.location-strRange.location;
				}
			}
			score += remainingScore*remainingStrRange.length;
			score /= strRange.length;
            CFRelease( userLoc );
			return score;
		}
	}
    CFRelease( userLoc );
	return 0;
}
