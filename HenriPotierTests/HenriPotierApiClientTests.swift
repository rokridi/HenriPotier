//
//  HenriPotierApiClientTests.swift
//  HenriPotierTests
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ObjectMapper
import OHHTTPStubs

@testable import HenriPotier
@testable import HenriPotierApiClient

class ApiRequestTests: QuickSpec {
    
    override func spec() {
        
        var apiClient: HenriPotierApiClient!
        
        beforeEach {
            apiClient = HenriPotierApiClient(baseURL: "http://domain.com")
        }
        
        describe("Fetch books") {
            
            context("when response is OK", {
                
                it("should return a list of Book objects.", closure: {
                    
                    stub(condition: isHost("domain.com")) { request in
                        return OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("books.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                    }
                    
                    waitUntil(action: { done in
                        
                        apiClient.fetchBooks(completion: { result in
                            expect(result.isSuccess).to(beTrue())
                            let books = result.value
                            expect(books).toNot(beNil())
                            expect(books?.count).to(equal(7))
                            
                            if let book = books?.first {
                                expect(book.isbn).to(equal("c8fabf68-8374-48fe-a7ea-a00ccd07afff"))
                                expect(book.price).to(equal(35))
                            }
                            done()
                        })
                    })
                })
                
                context("when JSON is invalid", {
                    
                    it("should return a JSON error.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("invalid_books.json", type(of: self))!,
                                statusCode: 200,
                                headers: ["Content-Type":"application/json"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchBooks() { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let books = result.value
                                expect(books).to(beNil())
                                
                                if case let ApiError.jsonMappingFailed(error: error) = result.error! {
                                    expect(error).toNot(beNil())
                                } else {
                                    fail("Error should be jsonMappingFailed.")
                                }
                                
                                done()
                            }
                        })
                    })
                })
                
                context("when response code is invalid", {
                    
                    it("should return a responseValidationFailed error with reason unacceptableStatusCode code 400.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("invalid_books.json", type(of: self))!,
                                statusCode: 400,
                                headers: ["Content-Type":"application/json"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchBooks() { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let books = result.value
                                expect(books).to(beNil())
                                
                                if case let ApiError.responseValidationFailed(reason: .unacceptableStatusCode(code: code)) = result.error! {
                                    expect(code).to(equal(400))
                                } else {
                                    fail("Error should be responseValidationFailed with reason unacceptableStatusCode code 400.")
                                }
                                
                                done()
                            }
                        })
                    })
                })
                
                context("when received content type is invalid.", {
                    it("should return a responseValidationFailed error with reason unacceptableContentType with responseContentType: application/xml.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("books.json", type(of: self))!,
                                statusCode: 200,
                                headers: ["Content-Type":"application/xml"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchBooks() { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let books = result.value
                                expect(books).to(beNil())
                                
                                if case let ApiError.responseValidationFailed(reason: .unacceptableContentType(acceptableContentTypes: _, responseContentType: received)) = result.error! {
                                    expect(received).to(equal("application/xml"))
                                } else {
                                    fail("Error should be responseValidationFailed with reason unacceptableStatusCode code 400.")
                                }
                                
                                done()
                            }
                        })
                    })
                })
            })
        }
        
        describe("Fetch offers") {
            
            context("when response is OK", {
                
                it("should return a list of Offer objects.", closure: {
                    
                    stub(condition: isHost("domain.com")) { request in
                        return OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("offers.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                    }
                    
                    waitUntil(action: { done in
                        
                        apiClient.fetchOffersFor(ISBNs: ["c8fabf68-8374-48fe-a7ea-a00ccd07afff", "a460afed-e5e7-4e39-a39d-c885c05db861"]) { result  in
                            
                            expect(result.isSuccess).to(beTrue())
                            let offers = result.value
                            expect(offers).toNot(beNil())
                            expect(offers?.count).to(equal(3))
                            
                            if let offers = offers, offers.count == 3 {
                                expect(offers.first!.type).to(equal(HPOfferType.percentage))
                                expect(offers.first!.value).to(equal(4))
                                expect(offers.first!.sliceValue).to(beNil())
                                
                                expect(offers[1].type).to(equal(HPOfferType.minus))
                                expect(offers[1].value).to(equal(15))
                                expect(offers[1].sliceValue).to(beNil())
                                
                                expect(offers.last!.type).to(equal(HPOfferType.slice))
                                expect(offers.last!.value).to(equal(12))
                                expect(offers.last!.sliceValue).to(equal(100))
                            }
                            done()
                        }
                    })
                })
                
                context("when JSON is invalid", {
                    
                    it("should return a JSON error.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("invalid_offers.json", type(of: self))!,
                                statusCode: 200,
                                headers: ["Content-Type":"application/json"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchOffersFor(ISBNs: ["c8fabf68-8374-48fe-a7ea-a00ccd07afff", "a460afed-e5e7-4e39-a39d-c885c05db861"]) { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let offers = result.value
                                expect(offers).to(beNil())
                                
                                if case let ApiError.jsonMappingFailed(error: error) = result.error! {
                                    expect(error).toNot(beNil())
                                } else {
                                    fail("Error should be jsonMappingFailed.")
                                }
                                
                                done()
                            }
                        })
                    })
                })
                
                context("when response code is invalid", {
                    
                    it("should return a responseValidationFailed error with reason unacceptableStatusCode code 400.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("offers.json", type(of: self))!,
                                statusCode: 400,
                                headers: ["Content-Type":"application/json"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchOffersFor(ISBNs: ["c8fabf68-8374-48fe-a7ea-a00ccd07afff", "a460afed-e5e7-4e39-a39d-c885c05db861"]) { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let offers = result.value
                                expect(offers).to(beNil())
                                
                                if case let ApiError.responseValidationFailed(reason: .unacceptableStatusCode(code: code)) = result.error! {
                                    expect(code).to(equal(400))
                                } else {
                                    fail("Error should be responseValidationFailed with reason unacceptableStatusCode code 400.")
                                }
                                
                                done()
                            }
                        })
                    })
                })
                
                context("when received content type is invalid.", {
                    it("should return a responseValidationFailed error with reason unacceptableContentType with responseContentType: application/xml.", closure: {
                        
                        stub(condition: isHost("domain.com")) { request in
                            
                            return OHHTTPStubsResponse(
                                fileAtPath: OHPathForFile("offers.json", type(of: self))!,
                                statusCode: 200,
                                headers: ["Content-Type":"application/xml"]
                            )
                        }
                        
                        waitUntil(action: { done in
                            
                            apiClient.fetchOffersFor(ISBNs: ["c8fabf68-8374-48fe-a7ea-a00ccd07afff", "a460afed-e5e7-4e39-a39d-c885c05db861"]) { result  in
                                
                                expect(result.isFailure).to(beTrue())
                                let offers = result.value
                                expect(offers).to(beNil())
                                
                                if case let ApiError.responseValidationFailed(reason: .unacceptableContentType(acceptableContentTypes: _, responseContentType: received)) = result.error! {
                                    expect(received).to(equal("application/xml"))
                                } else {
                                    fail("Error should be unacceptableContentType with received content type application/xml.")
                                }
                                done()
                            }
                        })
                    })
                })
            })
        }
    }
}
