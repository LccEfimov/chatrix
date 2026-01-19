def test_health(client) -> None:
    r = client.get("/v1/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
    assert r.headers["X-Correlation-Id"]
    assert r.headers["X-App-Name"] == "ChatriX API"


def test_health_preserves_correlation_id(client) -> None:
    r = client.get("/v1/health", headers={"X-Correlation-Id": "test-correlation"})
    assert r.status_code == 200
    assert r.headers["X-Correlation-Id"] == "test-correlation"
