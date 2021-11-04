//
//  Constants.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

let KEYWINDOW = UIApplication.shared.keyWindow

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

let LocationProvider:ATB_LocationProvider = ATB_LocationProvider()

let g_StrFeeds:[String] = ["My ATB", "Beauty", "Ladieswear", "Menswear", "Hair", "Kids", "Home", "Events", "Health & Well-Being", "Celebrations", "Miscellaneous"]

var g_myInfo = User()
var g_myToken = ""
var g_fromNotification:Bool = false

var g_deepLinkId: String = ""
var g_deepLinkType: String = "0"

//let DOMAIN_URL = "https://myatb.co.uk/"
//let DOMAIN_URL = "http://3.9.156.213/"
let DOMAIN_URL = "https://test.myatb.co.uk/"
//let API_BASE_URL = "https://myatb.co.uk/api/"
//let API_BASE_URL = "http://3.9.156.213/api/"
let API_BASE_URL = "https://test.myatb.co.uk/api/"

let INVITE_URL = DOMAIN_URL + "invite?code="

//let DOMAIN_URL = "http://localhost/ATB"
//let API_BASE_URL = "http://localhost/ATB/api/"

let STAGE_ONE_REGISTER_API = API_BASE_URL + "auth/register_stage_one"
let LOGIN_API = API_BASE_URL + "auth/login"
let REGISTER_API = API_BASE_URL + "auth/register"
let UPDATE_FEED_API = API_BASE_URL + "auth/update_feed"
let SEND_PWDRESETEMAIL_API = API_BASE_URL + "auth/forgot_pass_email_verification"
let RESETCODE_VERIFY_API = API_BASE_URL + "auth/check_verification_code"
let PWDRESET_API = API_BASE_URL + "auth/update_pass"
let PWDCHANGE_API = API_BASE_URL + "auth/change_pass"

let GET_PROFILE_API = API_BASE_URL + "profile/getprofile"
let UPDATE_PROFILE_API = API_BASE_URL + "profile/updateprofile"
let UPDATE_BIO_API = API_BASE_URL + "profile/updatebio"
let SET_POST_RANGE_API = API_BASE_URL + "profile/update_search_region"
let GET_FOLLOWER_API = API_BASE_URL + "profile/getfollower"

let GENERATE_EPHEMERAL_KEY = API_BASE_URL + "profile/generate_ephemeral_key"
let ADD_CARD_API = API_BASE_URL + "profile/add_payment"
let LOAD_CARDS_API = API_BASE_URL + "profile/get_cards"
let SET_PRIMARYCARD_API = API_BASE_URL + "profile/set_primary_card"
let DELETE_CARD_API = API_BASE_URL + "profile/remove_card"
let ADD_SUB = API_BASE_URL + "profile/add_sub"

let GET_BRAINTREE_CLIENT_TOKEN = API_BASE_URL + "profile/get_braintree_client_token"
let ADD_PP_SUB = API_BASE_URL + "profile/add_pp_sub"
let GET_PP_ADDRESS = API_BASE_URL + "profile/get_pp_add"
let MAKE_PP_PAYMENT = API_BASE_URL + "profile/make_pp_pay"
let GET_PP_TRANSACTIONS = API_BASE_URL + "profile/get_pp_transactions"

let ADD_SERVICE_API = API_BASE_URL + "profile/add_service"
let REMOVE_SERVICE_API = API_BASE_URL + "profile/remove_service"
let UPDATE_SERVICE_API = API_BASE_URL + "profile/update_service"

let LOAD_BUSINESS_API = API_BASE_URL + "profile/read_business_account"
let LOAD_BUSINESS_API_FROM_ID = API_BASE_URL + "profile/read_business_account_from_id"
let CREATE_BUSINESS_API = API_BASE_URL + "profile/create_business_account"
let UPDATE_BUSINESS_API = API_BASE_URL + "profile/update_business_account"
let UPDATE_BUSINESS_BIO = API_BASE_URL + "profile/update_business_bio"

let CREATE_POST_API = API_BASE_URL + "post/publish"
let UPDATE_POST_API = API_BASE_URL + "post/update_content"
let GET_SELECTED_FEED_API = API_BASE_URL + "post/get_feed"
let GET_ALL_FEED_API = API_BASE_URL + "post/get_home_feed"
let GET_POST_DETAIL_API = API_BASE_URL + "post/get_post_detail"
let GET_MULTI_GROUP_ID = API_BASE_URL + "post/get_multi_group_id"

let GET_PRODUCT_MULTI_GROUP_ID  =   API_BASE_URL + "profile/get_multi_group_id"

let ADD_VOTE = API_BASE_URL + "post/add_vote"
let GET_USER_VOTE = API_BASE_URL + "post/get_user_vote"

let REPORT_POST_API = API_BASE_URL + "post/add_report_post"
let POST_LIKE_API = API_BASE_URL + "post/add_like_post"
let WRITE_COMMENT_API = API_BASE_URL + "post/add_comment_post"
let REPLY_COMMENT_API = API_BASE_URL + "post/reply_comment_post"
let LOAD_REPLIES_API = API_BASE_URL + "post/get_sub_comment"

let GET_USER_BOOKMARKS = API_BASE_URL + "profile/get_user_bookmarks"
let ADD_USER_BOOKMARK = API_BASE_URL + "profile/add_user_bookmark"

let GET_FOLLOWER = API_BASE_URL + "profile/getfollower"
let GET_FOLLOW = API_BASE_URL + "profile/getfollow"
let ADD_FOLLOW = API_BASE_URL + "profile/addfollow"
let DELETE_FOLLOWER = API_BASE_URL + "profile/deletefollower"
let GET_FOLLOWER_COUNT = API_BASE_URL + "profile/getfollowercount"
let GET_FOLLOW_COUNT = API_BASE_URL + "profile/getfollowcount"
let GET_POST_COUNT = API_BASE_URL + "profile/getpostcount"

let GET_NOTIFICATIONS = API_BASE_URL + "profile/get_notifications"

let ADD_BUSINESS_REVIEWS = API_BASE_URL + "profile/addbusinessreviews"
let GET_BUSINESS_REVIEWS = API_BASE_URL + "profile/getbusinessreview"

let ADD_CONNECT_ACCOUNT = API_BASE_URL + "profile/add_connect_account"
let MAKE_PAYMENT = API_BASE_URL + "profile/make_payment"

let IS_SOLD = API_BASE_URL + "post/is_sold"
let SET_SOLD = API_BASE_URL + "post/set_sold"
let RELIST = API_BASE_URL + "post/relist"

let GET_TRANSACTIONS = API_BASE_URL + "profile/get_transactions"

let COUNT_SERVICE_POST = API_BASE_URL + "post/count_service_posts"
let COUNT_SALE_POST = API_BASE_URL + "post/count_sales_posts"

let GET_USERS_POSTS = API_BASE_URL + "profile/get_users_posts"

let GET_USER_PRODUCTS   =   API_BASE_URL + "profile/get_user_products"
let GET_USER_SERVICES   =   API_BASE_URL + "profile/get_services"

let UPDATE_NOTIFCATION_TOKEN = API_BASE_URL + "profile/update_notification_token"
let LIKE_NOTIFICATIONS = API_BASE_URL + "profile/like_notifications"
let HAS_LIKE_NOTIFICATIONS = API_BASE_URL + "profile/has_like_notifications"

let ADD_PRODUCT  =  API_BASE_URL + "profile/add_product"
let UPDATE_PRODUCT = API_BASE_URL + "profile/update_product"

let ADD_SERVICE  =  API_BASE_URL + "profile/add_service"
let UPDATE_SERVICE = API_BASE_URL + "profile/update_service"

let IS_USERNAME_USED = API_BASE_URL + "auth/is_username_used"

let DELETE_POST = API_BASE_URL + "post/delete_post"

let GET_CART_PRODUCTS = API_BASE_URL + "post/get_cart_products"

let GET_BUSINESS_ITEMS  =   API_BASE_URL + "profile/get_business_items"

let UPDATE_PRODUCT_VARIANT = API_BASE_URL + "profile/update_variant_product"

let GET_PURCHASES       =   API_BASE_URL + "transaction/get_purchases"
let GET_ITEMS_SOLD      =   API_BASE_URL + "transaction/get_items_sold"

let NOTIFICATION_COUNT  =   "Notification_Count"

struct Constants {

    static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."

    static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."

    static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
    
    static let settingsBtnTitle = "Settings"
    static let cancelBtnTitle = "Cancel"
    
    static let GENERAL_BACKEND_ERROR = "Something went wrong, please try again later."
}

