package com.wutiange.nativeesptouchv2

class EspTouch2Exception(
  val code: String,
  override val message: String
) : Exception(message)
