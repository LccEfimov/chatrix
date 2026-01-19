from sqlalchemy import select

from app.models.referral_reward import ReferralReward
from app.models.referral_tier import ReferralTier
from app.models.user import User


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _login(client, *, provider: str, provider_user_id: str, email: str) -> str:
    response = client.post(
        f"/v1/auth/oauth/{provider}/callback",
        json={"provider_user_id": provider_user_id, "email": email},
    )
    return response.json()["tokens"]["access_token"]


def test_referral_me_zero_plan(client) -> None:
    token = _login(
        client,
        provider="google",
        provider_user_id="referral-zero",
        email="referral-zero@example.com",
    )
    response = client.get("/v1/referrals/me", headers=_auth_headers(token))
    assert response.status_code == 200
    data = response.json()
    assert data["referral_enabled"] is False
    assert data["referral_code"] is None
    assert data["referral_url"] is None


def test_referral_rewards_and_tree(client, db_session) -> None:
    inviter_token = _login(
        client,
        provider="google",
        provider_user_id="referrer-1",
        email="referrer@example.com",
    )
    inviter = db_session.execute(
        select(User).where(User.email == "referrer@example.com")
    ).scalar_one()
    inviter.plan_code = "CORE"
    db_session.add(inviter)
    db_session.add(ReferralTier(plan_code="CORE", level=1, percent=3))
    db_session.commit()

    invitee_token = _login(
        client,
        provider="google",
        provider_user_id="invitee-1",
        email="invitee@example.com",
    )
    _login(
        client,
        provider="apple",
        provider_user_id="invitee-1-apple",
        email="invitee@example.com",
    )
    invitee = db_session.execute(
        select(User).where(User.email == "invitee@example.com")
    ).scalar_one()
    invitee.referrer_id = inviter.id
    db_session.add(invitee)
    db_session.commit()

    activate_response = client.post(
        "/v1/subscriptions/activate",
        json={"plan_code": "START"},
        headers=_auth_headers(invitee_token),
    )
    assert activate_response.status_code == 200

    rewards_response = client.get("/v1/referrals/rewards", headers=_auth_headers(inviter_token))
    assert rewards_response.status_code == 200
    rewards_data = rewards_response.json()["rewards"]
    assert len(rewards_data) == 1
    assert rewards_data[0]["paid_amount_cents"] == 50000
    assert rewards_data[0]["reward_amount_cents"] == 1500

    reward_row = db_session.execute(select(ReferralReward)).scalar_one()
    assert reward_row.referrer_id == inviter.id

    tree_response = client.get("/v1/referrals/tree", headers=_auth_headers(inviter_token))
    assert tree_response.status_code == 200
    tree_nodes = tree_response.json()["nodes"]
    assert tree_nodes == [
        {"level": 1, "user_id": str(invitee.id), "email": "invitee@example.com"}
    ]
