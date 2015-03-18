//
//  CHKApplePayAdditionsTest.m
//  CheckoutAnywhere
//
//  Created by Joshua Tessier on 2015-02-11.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//

@import UIKit;
@import XCTest;
@import PassKit;
@import AddressBook;

#import "CHKCheckout.h"
#import "CHKApplePayAdditions.h"

@interface CHKApplePayAdditionsTest : XCTestCase
@end

@implementation CHKApplePayAdditionsTest {
	CHKCheckout *_checkout;
}

- (void)setUp
{
	_checkout = [[CHKCheckout alloc] init];
}

#pragma mark - CHKCheckout Apple Pay additions

- (void)testSummaryItemsWithEmptyCheckout
{
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(2, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber zero], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber zero], [summaryItems[1] amount]);
}

- (void)testFullSummaryItems
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber decimalNumberWithString:@"2.00"];
	_checkout.totalTax = [NSDecimalNumber decimalNumberWithString:@"1.00"];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"4.00"];
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(4, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"SHIPPING", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.00"], [summaryItems[1] amount]);
	XCTAssertEqualObjects(@"TAXES", [summaryItems[2] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"1.00"], [summaryItems[2] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[3] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"4.00"], [summaryItems[3] amount]);
}

- (void)testSummaryItemsWithShippingRate
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber decimalNumberWithString:@"2.00"];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"3.00"];
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(3, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"SHIPPING", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.00"], [summaryItems[1] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[2] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"3.00"], [summaryItems[2] amount]);
}

- (void)testSummaryItemsWithFreeShippingAndTaxesShouldNotShowShippingOrTaxes
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber zero];
	_checkout.totalTax = [NSDecimalNumber zero];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"3.00"];
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(2, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"3.00"], [summaryItems[1] amount]);
}

- (void)testSummaryItemsWithZeroDiscount
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber zero];
	_checkout.totalTax = [NSDecimalNumber zero];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"3.00"];
	CHKDiscount *discount = [[CHKDiscount alloc] init];
	discount.code = @"BANANA";
	discount.amount = [NSDecimalNumber zero];
	discount.applicable = YES;
	_checkout.discount = discount;
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(2, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"3.00"], [summaryItems[1] amount]);
}

- (void)testSummaryItemsWithNonZeroDiscount
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber zero];
	_checkout.totalTax = [NSDecimalNumber zero];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"2.00"];
	CHKDiscount *discount = [[CHKDiscount alloc] init];
	discount.code = @"BANANA";
	discount.amount = [NSDecimalNumber one];
	discount.applicable = YES;
	_checkout.discount = discount;
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(3, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"DISCOUNT (BANANA)", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[1] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[2] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.00"], [summaryItems[2] amount]);
}

- (void)testSummaryItemsWithNonZeroCodelessDiscount
{
	_checkout.subtotalPrice = [NSDecimalNumber one];
	_checkout.shippingRate = [[CHKShippingRate alloc] init];
	_checkout.shippingRate.price = [NSDecimalNumber zero];
	_checkout.totalTax = [NSDecimalNumber zero];
	_checkout.totalPrice = [NSDecimalNumber decimalNumberWithString:@"2.00"];
	CHKDiscount *discount = [[CHKDiscount alloc] init];
	discount.code = @"";
	discount.amount = [NSDecimalNumber one];
	discount.applicable = YES;
	_checkout.discount = discount;
	
	NSArray *summaryItems = [_checkout summaryItems];
	XCTAssertEqual(3, [summaryItems count]);
	
	XCTAssertEqualObjects(@"SUBTOTAL", [summaryItems[0] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[0] amount]);
	XCTAssertEqualObjects(@"DISCOUNT", [summaryItems[1] label]);
	XCTAssertEqualObjects([NSDecimalNumber one], [summaryItems[1] amount]);
	XCTAssertEqualObjects(@"TOTAL", [summaryItems[2] label]);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"2.00"], [summaryItems[2] amount]);
}

#pragma mark - CHKShippingRate Apple Pay additions

- (void)testConvertShippingRatesToShippingMethods
{
	CHKShippingRate *rate1 = [[CHKShippingRate alloc] init];
	rate1.shippingRateIdentifier = @"1234";
	rate1.price = [NSDecimalNumber decimalNumberWithString:@"5.00"];
	rate1.title = @"Banana";
	
	CHKShippingRate *rate2 = [[CHKShippingRate alloc] init];
	rate2.shippingRateIdentifier = @"5678";
	rate2.price = [NSDecimalNumber decimalNumberWithString:@"3.00"];
	rate2.title = @"Dinosaur";
	
	NSArray *shippingMethods = [CHKShippingRate convertShippingRatesToShippingMethods:@[rate1, rate2]];
	XCTAssertEqual(2, [shippingMethods count]);
	
	PKShippingMethod *method1 = shippingMethods[0];
	XCTAssertEqualObjects(@"1234", method1.identifier);
	XCTAssertEqualObjects(@"Banana", method1.label);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"5.00"], method1.amount);
	
	PKShippingMethod *method2 = shippingMethods[1];
	XCTAssertEqualObjects(@"5678", method2.identifier);
	XCTAssertEqualObjects(@"Dinosaur", method2.label);
	XCTAssertEqualObjects([NSDecimalNumber decimalNumberWithString:@"3.00"], method2.amount);
}

- (void)testConvertShippingRatesToShippingMethodsWithEmptyArray
{
	NSArray *shippingMethods = [CHKShippingRate convertShippingRatesToShippingMethods:@[]];
	XCTAssertEqual(0, [shippingMethods count]);
}

#pragma mark - CHKAddress Apple Pay additions

- (void)testEmailFromRecord
{
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("Bob"), &error);
	ABRecordSetValue(person, kABPersonLastNameProperty, CFSTR("Banana"), &error);
	
	ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABStringPropertyType);
	ABMultiValueAddValueAndLabel(emails, CFSTR("bob@banana.com"), CFSTR("work"), nil);
	ABMultiValueAddValueAndLabel(emails, CFSTR("dino@banana.com"), CFSTR("home"), nil);
	ABRecordSetValue(person, kABPersonEmailProperty, emails, &error);
	CFRelease(emails);
	
	XCTAssertEqualObjects(@"bob@banana.com", [CHKAddress emailFromRecord:person]);
	
	CFRelease(person);
}

- (void)testEmailFromRecordWithoutAnEmail
{
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("Bob"), &error);
	ABRecordSetValue(person, kABPersonLastNameProperty, CFSTR("Banana"), &error);
	
	XCTAssertNil([CHKAddress emailFromRecord:person]);
	
	CFRelease(person);
}

- (void)testAddressFromRecord
{
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("Bob"), &error);
	ABRecordSetValue(person, kABPersonLastNameProperty, CFSTR("Banana"), &error);
	
	ABMutableMultiValueRef addresses = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	CFMutableDictionaryRef address = CFDictionaryCreateMutable(kCFAllocatorDefault, 10, nil, nil);
	CFDictionarySetValue(address, kABPersonAddressStreetKey, CFSTR("150 Elgin Street"));
	CFDictionarySetValue(address, kABPersonAddressCityKey, CFSTR("Ottawa"));
	CFDictionarySetValue(address, kABPersonAddressStateKey, CFSTR("Ontario"));
	CFDictionarySetValue(address, kABPersonAddressZIPKey, CFSTR("K1N5T5"));
	CFDictionarySetValue(address, kABPersonAddressCountryKey, CFSTR("Canada"));
	
	ABMultiValueAddValueAndLabel(addresses, address, CFSTR("Shipping"), nil);
	CFRelease(address);
	
	ABRecordSetValue(person, kABPersonAddressProperty, addresses, &error);
	CFRelease(addresses);
	
	CHKAddress *newAddress = [CHKAddress addressFromRecord:person];
	XCTAssertNotNil(newAddress);
	XCTAssertEqualObjects(@"150 Elgin Street", newAddress.address1);
	XCTAssertEqualObjects(@"Ottawa", newAddress.city);
	XCTAssertEqualObjects(@"Ontario", newAddress.province);
	XCTAssertEqualObjects(@"K1N5T5", newAddress.zip);
	XCTAssertEqualObjects(@"Canada", newAddress.country);
	
	CFRelease(person);
}

- (void)testAddressFromRecordWithoutNameOrStreet
{
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	
	ABMutableMultiValueRef addresses = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	CFMutableDictionaryRef address = CFDictionaryCreateMutable(kCFAllocatorDefault, 10, nil, nil);
	CFDictionarySetValue(address, kABPersonAddressCityKey, CFSTR("Ottawa"));
	CFDictionarySetValue(address, kABPersonAddressStateKey, CFSTR("Ontario"));
	CFDictionarySetValue(address, kABPersonAddressZIPKey, CFSTR("K1N5T5"));
	CFDictionarySetValue(address, kABPersonAddressCountryKey, CFSTR("Canada"));
	
	ABMultiValueAddValueAndLabel(addresses, address, CFSTR("Shipping"), nil);
	CFRelease(address);
	
	ABRecordSetValue(person, kABPersonAddressProperty, addresses, &error);
	CFRelease(addresses);
	
	ABRecordSetValue(person, kABPersonFirstNameProperty, CFSTR("---"), &error);
	ABRecordSetValue(person, kABPersonLastNameProperty, CFSTR("---"), &error);
	
	CHKAddress *newAddress = [CHKAddress addressFromRecord:person];
	XCTAssertNotNil(newAddress);
	XCTAssertEqualObjects(@"---", newAddress.address1);
	XCTAssertEqualObjects(@"Ottawa", newAddress.city);
	XCTAssertEqualObjects(@"Ontario", newAddress.province);
	XCTAssertEqualObjects(@"K1N5T5", newAddress.zip);
	XCTAssertEqualObjects(@"Canada", newAddress.country);
	
	CFRelease(person);
}

@end