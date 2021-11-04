//
//  STPUrls.swift
//  ATB
//
//  Created by mobdev on 24/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

let STP_PK = "pk_test_vSm2y8pS6d0TXB2pZ4ppvLox"
let STP_SK = "sk_test_6s7CUq8T7LJPgiqlrZUEa2Sk"
let STP_BASE_URL = "https://api.stripe.com"

let STP_GET_CUSTOMER = STP_BASE_URL + "/v1/customers/" + g_myInfo.stp_cus_id
let STP_GET_SOURCES = STP_BASE_URL + "/v1/customers/" + g_myInfo.stp_cus_id + "/sources"
