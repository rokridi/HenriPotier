//
//  ModelsTests.swift
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

class ModelsTests: QuickSpec {
    
    override func spec() {
        
        describe("HPBook") {
            
            context("Valid book", {
                
                it("should create a valid book with valid parameters", closure: {
                    let book = HPBook(isbn: "c8fabf68-8374-48fe-a7ea-a00ccd07afff", title: "Henri Potier", price: 30, cover: "https://domain.com/image.png", synopsis: ["Once again"])
                    expect(book.isbn).to(equal("c8fabf68-8374-48fe-a7ea-a00ccd07afff"))
                    expect(book.title).to(equal("Henri Potier"))
                    expect(book.price).to(equal(30))
                    expect(book.synopsis).to(equal(["Once again"]))
                })
                
                it("should create a valid book from Book instance", closure: {
                    let apiBook = Book(isbn: "c8fabf68-8374-48fe-a7ea-a00ccd07afff", title: "Henri Potier", price: 30, cover: "https://domain.com/image.png", synopsis: ["synopsis"])
                    let book = HPBook(book: apiBook)
                    
                    expect(book.isbn).to(equal("c8fabf68-8374-48fe-a7ea-a00ccd07afff"))
                    expect(book.title).to(equal("Henri Potier"))
                    expect(book.price).to(equal(30))
                    expect(book.synopsis).to(equal(["synopsis"]))
                })
            })
        }
        
        describe("HPOffer") {
            
            let price = 100
            
            context("Valid Offer with parameters", {
                
                it("Should create a Percentage offer.", closure: {
                    let offer = HPOffer(type: .percentage, value: 10, sliceValue: nil)
                    
                    expect(offer.type).to(equal(HPOfferType.percentage))
                    expect(offer.value).to(equal(10))
                    expect(offer.sliceValue).to(beNil())
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(90))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(price))
                })
                
                it("Should create a Minus offer.", closure: {
                    let offer = HPOffer(type: .minus, value: 11, sliceValue: nil)
                    
                    expect(offer.type).to(equal(HPOfferType.minus))
                    expect(offer.value).to(equal(11))
                    expect(offer.sliceValue).to(beNil())
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(89))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(price))
                })
                
                it("Should create a Slice offer.", closure: {
                    let offer = HPOffer(type: .slice, value: 12, sliceValue: 100)
                    
                    expect(offer.type).to(equal(HPOfferType.slice))
                    expect(offer.value).to(equal(12))
                    expect(offer.sliceValue).to(equal(100))
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(88))
                })
            })
            
            context("Valid HPOffer from Offer instance.", {
                
                it("should create a Percentage offer", closure: {
                    let apiOffer = Offer(type: .percentage, value: 10, sliceValue: nil)
                    let offer = HPOffer(offer: apiOffer)
                    
                    expect(offer.type).to(equal(HPOfferType.percentage))
                    expect(offer.value).to(equal(10))
                    expect(offer.sliceValue).to(beNil())
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(90))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(price))
                })
                
                it("should create a Minus offer", closure: {
                    let apiOffer = Offer(type: .minus, value: 11, sliceValue: nil)
                    let offer = HPOffer(offer: apiOffer)
                    
                    expect(offer.type).to(equal(HPOfferType.minus))
                    expect(offer.value).to(equal(11))
                    expect(offer.sliceValue).to(beNil())
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(89))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(price))
                })
                
                it("should create a Slice offer", closure: {
                    let apiOffer = Offer(type: .slice, value: 12, sliceValue: 100)
                    let offer = HPOffer(offer: apiOffer)
                    
                    expect(offer.type).to(equal(HPOfferType.slice))
                    expect(offer.value).to(equal(12))
                    expect(offer.sliceValue).to(equal(100))
                    expect(offer.priceWithPercentageReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithMinusReductionFor(price: price)).to(equal(price))
                    expect(offer.priceWithSliceReductionFor(price: price)).to(equal(88))
                })
            })
        }
    }
}
