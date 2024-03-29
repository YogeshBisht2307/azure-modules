package com.kodeweich;
import com.microsoft.azure.functions.HttpMethod;
import com.microsoft.azure.functions.HttpRequestMessage;
import com.microsoft.azure.functions.HttpResponseMessage;
import com.microsoft.azure.functions.HttpStatus;
import com.microsoft.azure.functions.HttpStatusType;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class HttpRequest implements HttpRequestMessage<Optional<String>> {

    private final URI uri;

    private final HttpMethod httpMethod;

    private final Map<String, String> headers;

    private final Map<String, String> queryParameters;

    private final Object body;

    private HttpRequest(URI uri,
                       HttpMethod httpMethod,
                       Map<String, String> headers,
                       Map<String, String> queryParameters,
                       Object body) {
        this.uri = uri;
        this.httpMethod = httpMethod;
        this.headers = headers;
        this.queryParameters = queryParameters;
        this.body = body;
    }

    @Override
    public URI getUri() {
        return this.uri;
    }

    @Override
    public HttpMethod getHttpMethod() {
        return this.httpMethod;
    }

    @Override
    public Map<String, String> getHeaders() {
        return this.headers;
    }

    @Override
    public Map<String, String> getQueryParameters() {
        return this.queryParameters;
    }

    @Override
    public Optional<String> getBody() {
        return bodyAsString(this.body);
    }

    @Override
    public HttpResponseMessage.Builder createResponseBuilder(HttpStatus status) {
        return new ResponseBuilder().status(status);
    }

    @Override
    public HttpResponseMessage.Builder createResponseBuilder(HttpStatusType status) {
        return new ResponseBuilder().status(status);
    }

    private Optional<String> bodyAsString(Object body) {
        if (body instanceof byte[]) {
            return Optional.of(new String((byte[]) body, StandardCharsets.UTF_8));
        } else if (body != null) {
            return Optional.of(body.toString());
        }
        return Optional.empty();
    }

    public static Builder builder() {
        return new HttpRequest.Builder();
    }

    public static class Builder {
        private URI uri;

        private HttpMethod httpMethod;

        private Map<String, String> headers;

        private Map<String, String> queryParameters;

        private Object body;

        public Builder uri(URI uri) {
            this.uri = uri;
            return this;
        }

        public Builder httpMethod(HttpMethod httpMethod) {
            this.httpMethod = httpMethod;
            return this;
        }

        public Builder header(String header, String value) {
            if (headers == null) {
                headers = new HashMap<>();
            }
            this.headers.put(header, value);
            return this;
        }

        public Builder query(String name, String value) {
            if (queryParameters == null) {
                queryParameters = new HashMap<>();
            }
            this.queryParameters.put(name, value);
            return this;
        }

        public HttpRequestMessage<Optional<String>> build() {
            return new HttpRequest(uri, httpMethod,
                    headers == null ? Collections.emptyMap() : headers,
                    queryParameters == null ? Collections.emptyMap() : queryParameters,
                    body);
        }
    }
}
