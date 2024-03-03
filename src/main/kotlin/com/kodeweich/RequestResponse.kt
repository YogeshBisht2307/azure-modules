package com.kodeweich

import io.micronaut.serde.annotation.Serdeable

@Serdeable
data class SampleInputMessage(val name: String)

@Serdeable
data class SampleReturnMessage(val returnMessage: String)
