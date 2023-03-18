//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Ashish Jaiswal on 18/03/23.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
