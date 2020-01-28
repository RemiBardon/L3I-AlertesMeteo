//
//  ImagesTests.swift
//  AlertesMeteoTests
//
//  Created by BARDON Rémi on 26/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import XCTest

class ImagesTests: XCTestCase {

    func testImagesAreAvailable() {
		for image in Images.allCases {
			if let uiImage = UIImage(named: image.rawValue) {
				XCTAssertEqual(image.uiImage, uiImage, "\(image.rawValue)")
			} else {
				XCTFail(image.rawValue)
			}
		}
    }

}
