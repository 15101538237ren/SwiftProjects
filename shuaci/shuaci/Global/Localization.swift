//
//  Localization.swift
//  shuaci
//
//  Created by Honglei on 4/4/21.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation

// MARK: - UI
let loadingText:String = NSLocalizedString("加载中", comment: "")
let dataLoadingText:String = NSLocalizedString("数据加载中..", comment: "")
let gettingVocabsText:String = NSLocalizedString("获取单词中..", comment: "")
let ensureText:String = NSLocalizedString("确定", comment: "")
let cancelText:String = NSLocalizedString("取消", comment: "")
let yesText:String = NSLocalizedString("是", comment: "")
let noText:String = NSLocalizedString("否", comment: "")
let okText:String = NSLocalizedString("好的", comment: "")
let promptText:String = NSLocalizedString("提示", comment: "")
let agreeText:String = NSLocalizedString("同意", comment: "")
let refuseText:String = NSLocalizedString("不同意", comment: "")

// Login VC
let loginText:String = NSLocalizedString("登录", comment: "")
let registerText:String = NSLocalizedString("注册", comment: "")
let emailText:String = NSLocalizedString("邮 箱", comment: "")
let pwdText:String = NSLocalizedString("密 码", comment: "")
let invitationCodePlaceholderText:String = NSLocalizedString("邀请码", comment: "")
let phoneNumText:String = NSLocalizedString("手机号", comment: "")
let verificationCodeText:String = NSLocalizedString("短信验证码", comment: "")
let emailLoginText:String = NSLocalizedString("邮箱登录", comment: "")
let phoneLoginText:String = NSLocalizedString("手机号登录", comment: "")
let resetPwdLoginText:String = NSLocalizedString("邮箱登录", comment: "")
let sendingText:String = NSLocalizedString("正在发送", comment: "")
let verficationSentText:String = NSLocalizedString("验证码已发送!", comment: "")
let wrongVerficationText:String = NSLocalizedString("验证码有误!", comment: "")
let sendFailedText:String = NSLocalizedString("发送失败", comment: "")
let resendText:String = NSLocalizedString("重新发送", comment: "")
let resendLaterText:String = NSLocalizedString("后重新发送", comment: "")
let wrongEmailFormatText:String = NSLocalizedString("邮箱格式不正确!", comment: "")
let wrongPhoneFormatText:String = NSLocalizedString("手机号有误!", comment: "")
let emptyPhoneText:String = NSLocalizedString("请输入手机号～", comment: "")
let emptyVerificationText:String = NSLocalizedString("请输入验证码!", comment: "")
let wrongPwdText:String = NSLocalizedString("密码不正确!", comment: "")
let emptyEmailText:String = NSLocalizedString("邮箱不能为空!", comment: "")
let pwdFormatText:String = NSLocalizedString("密码应为8-15位，且只包含字母、数字或下划线", comment: "")
let loggingText:String = NSLocalizedString("正在登录", comment: "")
let registerEmailText:String = NSLocalizedString("该邮箱尚未注册,是否注册?", comment: "")
let emailUnregisteredText:String = NSLocalizedString("该邮箱尚未注册!", comment: "")
let registerPhoneText:String = NSLocalizedString("该手机号尚未注册,是否注册?", comment: "")
let logginErrorText:String = NSLocalizedString("登录错误,请稍后再试", comment: "")
let verifyEmailPlsText:String = NSLocalizedString("请前往邮箱，并完成验证", comment: "")
let loginTooFastText:String = NSLocalizedString("登录请求太快，请等待30秒!", comment: "")
let emailExistText:String = NSLocalizedString("该邮箱已注册!", comment: "")
let errorText:String = NSLocalizedString("错误", comment: "")
let errorRetryText:String = NSLocalizedString("出现错误，请重试", comment: "")
let loginFailedText:String = NSLocalizedString("登录失败，请稍后重试", comment: "")
let resetEmailSentToText:String = NSLocalizedString("密码重置邮件已发送至", comment: "")
let emailSentWaitText:String = NSLocalizedString("邮件已发送，如需重新发送，请等待1分钟!", comment: "")
let emailSentToText:String = NSLocalizedString("已发送验证邮件到", comment: "")
let clickVerifyPlsText:String = NSLocalizedString("请您单击邮件中的链接，完成验证后登录!", comment: "")
let invitationPromptTitle:String = NSLocalizedString("邀请码", comment: "")
let invitationPromptText:String = NSLocalizedString("感谢您关注刷词，目前我们在内测阶段，需要邀请码方能注册。如您对内测感兴趣，可以关注微信公众号: 刷词+，来联系创始人获取", comment: "")


let feedbackWayTitle:String = NSLocalizedString("反馈方法", comment: "")
let feedbackWayDetail:String = NSLocalizedString("想要反馈给开发者吗？关注公众号：刷词+，单击「我要反馈」并填写反馈内容，我们就可以看见啦😊", comment: "")

let invitationIncorrect:String = NSLocalizedString("邀请码不正确", comment: "")

// MainPanel VC
let downloadingWallpaperText:String = NSLocalizedString("正在下载壁纸...", comment: "")
let downloadingBookText:String = NSLocalizedString("正在下载词库...", comment: "")
let downloadingBooksInHistoryText:String = NSLocalizedString("正在下载历史词库...", comment: "")
let syncingDataText:String = NSLocalizedString("正在同步数据...", comment: "")
let downloadRecordFailedText:String = NSLocalizedString("从云端下载学习记录失败，请稍后再试!🙁", comment: "")
let noBookSelectedText:String = NSLocalizedString("您还没有选择词库😅", comment: "")
let reviewJustLearnedText:String = NSLocalizedString("复习刚学", comment: "")
let reviewLearnedInHistoryText:String = NSLocalizedString("复习历史", comment: "")

// UserProfile VC
let learnedProgressText:String = NSLocalizedString("已学", comment: "")
let setFailedTryLaterText:String = NSLocalizedString("设置失败，请稍后重试!", comment: "")
let setNickNameText:String = NSLocalizedString("设置昵称", comment: "")
let inputNickNameText:String = NSLocalizedString("请输入你喜欢的昵称", comment: "")
let isLoggingOffText:String = NSLocalizedString("确定注销?", comment: "")
let zoomOrDragText:String = NSLocalizedString("「缩放」或「拖拽」来调整", comment: "")

// Book VC
let tenThousandText:String = NSLocalizedString("万", comment: "")

// Learning VC
let masterText:String = NSLocalizedString("掌握", comment: "")
let rememberedText:String = NSLocalizedString("会了", comment: "")
let forgetText:String = NSLocalizedString("不熟", comment: "")
let firstLearningText:String = NSLocalizedString("初记忆", comment: "")
let reLearningText:String = NSLocalizedString("再记忆", comment: "")
let firstReviewText:String = NSLocalizedString("初回忆", comment: "")
let cnToEnText:String = NSLocalizedString("中忆英", comment: "")
let enToCnText:String = NSLocalizedString("英忆中", comment: "")
let giveupEnsureText:String = NSLocalizedString("确定「放弃学习」?", comment: "")
let mottoText:String = NSLocalizedString("伟大的作品不是靠力量，而是靠坚持来完成的。——约翰逊", comment: "")
let saveReviewRecordText:String = NSLocalizedString("是否保存当前复习记录?", comment: "")
var notification_content = NSLocalizedString("\(nicknameOfApp)提醒您，根据记忆规律，现在复习单词记忆效果翻倍哦！", comment: "")
let interpLabelText:String = NSLocalizedString("双解释义", comment: "")

// Setting VC
let autoPronounceText:String = NSLocalizedString("自动发音", comment: "")
let pronounceTypeText:String = NSLocalizedString("发音类型", comment: "")
let setLearningPlanText:String = NSLocalizedString("设置学习计划", comment: "")
let everyDayNotificationText:String = NSLocalizedString("每日提醒", comment: "")
let rateAppText:String = NSLocalizedString("评价应用", comment: "")
let feedBackText:String = NSLocalizedString("意见反馈", comment: "")
let serviceTermText:String = NSLocalizedString("服务条款", comment: "")
let privacyText:String = NSLocalizedString("隐私政策", comment: "")
let onText:String = NSLocalizedString("开", comment: "")
let offText:String = NSLocalizedString("关", comment: "")
let usText:String = NSLocalizedString("美", comment: "")
let ukText:String = NSLocalizedString("英", comment: "")
let defaultPlanText:String = NSLocalizedString("乱序,20个/组", comment: "")
let randomOrderText:String = NSLocalizedString("乱序", comment: "")
let alphabetOrderText:String = NSLocalizedString("顺序", comment: "")
let reversedText:String = NSLocalizedString("倒序", comment: "")
let unitText:String = NSLocalizedString("个/组", comment: "")
let planSetText:String = NSLocalizedString("已设置每日提醒:", comment: "")
let feedBackTitleText:String = NSLocalizedString("评价反馈", comment: "")
let askExperienceText:String = NSLocalizedString("您在本应用使用体验如何?", comment: "")
let greatResponseText:String = NSLocalizedString("很赞!必须五星好评", comment: "")
let awefulResponseText:String = NSLocalizedString("用的不爽，反馈意见给开发者", comment: "")
let canNotSendEmailText:String = NSLocalizedString("无法发送邮件，请检查网络或设置!", comment: "")
let emailTitleText:String = NSLocalizedString("「刷词」意见反馈", comment: "")
let thanksForFeedbackText:String = NSLocalizedString("感谢您的反馈！我们会认真阅读您的意见,并在1-3天内给您回复", comment: "")

// WordHistory VC
let removeFromMasteredText:String = NSLocalizedString("移出已掌握", comment: "")
let reviewSelectedText:String = NSLocalizedString("复习选中", comment: "")
let selectWordsText:String = NSLocalizedString("选择词汇", comment: "")
let selectedAllText:String = NSLocalizedString("已全选", comment: "")
let unselectedAllText:String = NSLocalizedString("已清除全选", comment: "")
let removedSuccessfullyText:String = NSLocalizedString("移出成功😊", comment: "")
let masteredText:String = NSLocalizedString("已掌握", comment: "")
let rememberSeqText:String = NSLocalizedString("连续记住", comment: "")
let timesText:String = NSLocalizedString("次", comment: "")
let wordsText:String = NSLocalizedString("词", comment: "")
let noWordText:String = NSLocalizedString("无单词", comment: "")
let daysText:String = NSLocalizedString(" 天", comment: "")
let hoursText:String = NSLocalizedString("时", comment: "")
let minsText:String = NSLocalizedString("分", comment: "")
let secsText:String = NSLocalizedString("秒", comment: "")
let dayShortText:String = NSLocalizedString("天", comment: "")
let tillText:String = NSLocalizedString("距第", comment: "")
let reviewTurnText:String = NSLocalizedString("轮复习", comment: "")
let overduePreText:String = NSLocalizedString("第", comment: "")
let overdueNumText:String = NSLocalizedString("轮逾期", comment: "")
let userText:String = NSLocalizedString("人", comment: "")
let learningLabelText:String = NSLocalizedString("正在学习", comment: "")

// Reminder VC
let reminderFmtText:String = NSLocalizedString("MM月dd日 HH:mm", comment: "")
let notificationBodyText:String = NSLocalizedString("你的努力，终将成就自己。开始今天的单词学习吧😊", comment: "")


// SetMemOpt VC
let dateFmtText:String = NSLocalizedString("YYYY年MM月dd日", comment: "")

// learnReviewFinished VC
let loadingDakaText:String = NSLocalizedString("正在加载打卡数据😊..", comment: "")
let basedOnMemLawsText:String = NSLocalizedString("根据遗忘规律，", comment: "")
let willText:String = NSLocalizedString("将在", comment: "")
let willRemindText:String = NSLocalizedString("提醒您复习🙂", comment: "")

let reminderSettingText:String = NSLocalizedString("每日提醒", comment: "")
let reminderAskingText:String = NSLocalizedString("是否设置每日学习提醒?", comment: "")

// wordDetail VC
let getWordText:String = NSLocalizedString("获取单词中..", comment: "")

// FilterVocabs VC
let youDidNothingText:String = NSLocalizedString("您什么也没做☹️", comment: "")
let geText:String = NSLocalizedString("个", comment: "")


// Membership VC
let noHistoryPurchaseText:String = NSLocalizedString("无历史购买", comment: "")
let purchaseFailedText:String = NSLocalizedString("购买失败", comment: "")
let restorePurchaseSuccessText:String = NSLocalizedString("恢复购买成功", comment: "")
let restorePurchaseFailedText:String = NSLocalizedString("恢复购买失败", comment: "")
let unknownErrText:String = NSLocalizedString("未知错误，请反馈至客服", comment: "")
let purchaseCanceledText:String = NSLocalizedString("购买被取消", comment: "")
let paymentNotAllowedText:String = NSLocalizedString("系统购买功能被您禁止", comment: "")
let storeProductNotAvailableText:String = NSLocalizedString("当前产品不支持在您所在的国家购买", comment: "")
let VIPTitleText:String = NSLocalizedString("会员功能", comment: "")
let redeemBtnText:String = NSLocalizedString("兑换码", comment: "")
let tryNowText:String = NSLocalizedString("立即试用!", comment: "")
let beVIPText:String = NSLocalizedString("成为会员!", comment: "")
let restoreText:String = NSLocalizedString("恢复购买", comment: "")
let subscriptionTermText:String = NSLocalizedString("订阅服务协议", comment: "")

let freetrialText:String = NSLocalizedString("免费试用", comment: "")

let monthSubscriptionText:String = NSLocalizedString("连续包月", comment: "")

let quarterSubscriptionText:String = NSLocalizedString("连续包季", comment: "")

let yearSubscriptionText:String = NSLocalizedString("连续包年", comment: "")

let subscriptionDescription:String = NSLocalizedString("自动续费服务说明：\n1. 确认购买并付款后计入iTunes 账号。\n2. 可随时取消自动续费。如需取消，请在订阅到期24小时前，手动在 iTunes/Apple ID 订阅管理中关闭自动续费。\n3. 苹果 iTunes 账号会在到期前24小时内扣款，扣款成功后订阅顺延一个周期。", comment: "")

// MARK: - Themes
let lightText:String = NSLocalizedString("明 亮", comment: "")
let darkText:String = NSLocalizedString("深 邃", comment: "")
let pinkText:String = NSLocalizedString("粉 色", comment: "")
let redText:String = NSLocalizedString("红 色", comment: "")
let orangeText:String = NSLocalizedString("橙 色", comment: "")
let greenText:String = NSLocalizedString("绿 色", comment: "")
let blueText:String = NSLocalizedString("蓝 色", comment: "")
let purpleText:String = NSLocalizedString("紫 色", comment: "")
let brownText:String = NSLocalizedString("棕 色", comment: "")
let nightText:String = NSLocalizedString("深 夜", comment: "")

// MARK: - Toasts
let noVocabToReviewText:String = NSLocalizedString("您当前没有待复习的单词，\n放松一下吧😊", comment: "")

let notificationRejectedText:String = NSLocalizedString("您拒绝了开启「通知」，\(nicknameOfApp)将无法提醒您复习☹️。如需提醒，您可以前往「设置」，手动开启「通知」权限。", comment: "")

// Learning VC
let noDictMeaningText:String = NSLocalizedString("无词典解释☹️", comment: "")
let firstCardText:String = NSLocalizedString("已经是第一张啦!", comment: "")

// loadLearning VC
let readyStartText:String = NSLocalizedString("准备开始", comment: "")
let learningStr:String = NSLocalizedString("学习", comment: "")
let reviewStr:String = NSLocalizedString("复习", comment: "")
let numPeopleLearningText:String = NSLocalizedString("人正在与你一起刷词", comment: "")
let timesLabelText:String = NSLocalizedString("次 ", comment: "")
let quitLearningText:String = NSLocalizedString("退出学习", comment: "")
let giveupText:String = NSLocalizedString("放弃", comment: "")

// MARK: - Alert & Notifications

let nicknameOfApp:String = NSLocalizedString("小刷", comment: "")
let NoNetworkStr: String = NSLocalizedString("没有网络,请检查网络连接!", comment: "")

let UserDisabledTitle: String = NSLocalizedString("您的账号目前已被封禁", comment: "")
let UserDisabledContent: String = NSLocalizedString("如有疑问，请联系:\(OfficialEmail)", comment: "")

let everydayNotificationText: String = NSLocalizedString("我们需要开启「通知」权限，来每日提醒您复习。", comment: "")

let ebbinhausNotificationText: String = NSLocalizedString("我们需要开启「通知」权限来根据「艾宾浩斯遗忘规律」，提醒您在最高效的时间复习。", comment: "")

let welcomeText: String = NSLocalizedString("欢迎使用「刷词」，请您仔细阅读隐私协议和服务条款，并确定您是否同意我们的规则。我们深知个人信息的重要性，并且会全力保护您的个人信息安全可靠。", comment: "")

let notificationRequiredTitleText: String = NSLocalizedString("需要打开「通知」权限", comment: "")
let privacyAndTermsTitleText: String = NSLocalizedString("隐私协议与服务条款", comment: "")


