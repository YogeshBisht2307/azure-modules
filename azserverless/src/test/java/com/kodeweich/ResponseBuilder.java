package com.kodeweich;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.microsoft.azure.functions.HttpStatus;
import com.microsoft.azure.functions.HttpStatusType;
import io.micronaut.core.util.CollectionUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ResponseBuilder implements HttpResponseMessage.Builder, HttpResponseMessage {

    private HttpStatusType status = HttpStatus.OK;
    private final Map<String, List<String>> headers = new LinkedHashMap<>(3);
    private Object body;

    @Override
    public HttpResponseMessage.Builder status(HttpStatusType status) {
        this.status = status;
        return this;
    }

    @Override
    public HttpResponseMessage.Builder header(String key, String value) {
        headers.computeIfAbsent(key, (k) -> new ArrayList<>()).add(value);
        return this;
    }

    @Override
    public HttpResponseMessage.Builder body(Object body) {
        this.body = body;
        return this;
    }

    @Override
    public HttpResponseMessage build() {
        return this;
    }

    @Override
    public HttpStatusType getStatus() {
        return status;
    }

    @Override
    public String getHeader(String key) {
        List<String> v = headers.get(key);
        if (CollectionUtils.isNotEmpty(v)) {
            return v.iterator().next();
        }
        return null;
    }

    @Override
    public Object getBody() {
        return this.body;
    }
}
