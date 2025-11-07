public with sharing class HttpClient {
  private String namedCredential;
  private String endpoint;
  private Map<String, String> headers;
  private Integer timeout;

  public HttpClient(String namedCredential, String endpoint) {
    this.namedCredential = namedCredential;
    this.endpoint = endpoint;
    this.headers = new Map<String, String>();
    this.timeout = 120000;
  }

  public HttpResponse get() {
    return send('GET', null);
  }

  public HttpResponse patch(String body) {
    return send('PATCH', body);
  }

  public HttpResponse post(String body) {
    return send('POST', body);
  }

  public HttpClient setHeader(String key, String value) {
    this.headers.put(key, value);
    return this;
  }

  public HttpClient setTimeout(Integer timeout) {
    this.timeout = timeout;
    return this;
  }

  private HttpResponse send(String method, String body) {
    HttpRequest request = buildRequest(method, body);
    Http http = new Http();
    try {
      return http.send(request);
    } catch (Exception e) {
      throw new HttpClientException(
        'there was an error with the API : ' + e.getMessage()
      );
    }
  }

  private HttpRequest buildRequest(String method, String body) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint('Callout:' + namedCredential + endpoint);
    request.setMethod(method);
    request.setTimeout(timeout);
    for (String key : headers.keySet()) {
      request.setHeader(key, headers.get(key));
    }

    if (body != null)
      request.setBody(body);

    return request;
  }

  public class HttpClientException extends Exception {
  }
}
