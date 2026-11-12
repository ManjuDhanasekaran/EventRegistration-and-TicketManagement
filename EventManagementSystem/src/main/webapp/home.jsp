
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>



<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Eventify | Discover Events</title>

<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: "Segoe UI", Arial, sans-serif;
        background: #f7f8fc;
        color: #20243a;
        line-height: 1.6;
    }

    a {
        text-decoration: none;
        color: inherit;
    }


    .hero {
        margin: 34px auto 0;
        width: 86%;
        min-height: 440px;
        border-radius: 28px;
        overflow: hidden;
        position: relative;
        display: flex;
        align-items: center;
        padding: 60px;
        color: white;
        background:
            radial-gradient(circle at 85% 20%, rgba(255,255,255,.18), transparent 25%),
            radial-gradient(circle at 75% 90%, rgba(255,174,117,.35), transparent 28%),
            linear-gradient(115deg, #30206f, #6546e8 58%, #9475ff);
    }

    .hero::after {
        content: "✦";
        position: absolute;
        right: 9%;
        top: 12%;
        font-size: 100px;
        color: rgba(255,255,255,.16);
        transform: rotate(15deg);
    }

    .hero-content {
        position: relative;
        z-index: 1;
        max-width: 620px;
    }

    .eyebrow {
        display: inline-block;
        background: rgba(255,255,255,.15);
        border: 1px solid rgba(255,255,255,.22);
        padding: 8px 14px;
        border-radius: 30px;
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .5px;
        margin-bottom: 22px;
    }

    .hero h1 {
        font-size: clamp(36px, 5vw, 57px);
        line-height: 1.13;
        letter-spacing: -1.7px;
        margin-bottom: 20px;
    }

    .hero h1 span {
        color: #ffda9e;
    }

    .hero p {
        color: #e6e0ff;
        font-size: 16px;
        max-width: 510px;
        margin-bottom: 30px;
    }

    .hero-buttons {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
    }

    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 13px 22px;
        border-radius: 12px;
        font-size: 14px;
        font-weight: 700;
        transition: .2s ease;
    }

    .btn-primary {
        background: #ffffff;
        color: #5136cc;
    }

    .btn-primary:hover {
        background: #fff1d9;
        transform: translateY(-2px);
    }

    .btn-secondary {
        color: white;
        border: 1px solid rgba(255,255,255,.45);
        background: rgba(255,255,255,.08);
    }

    .btn-secondary:hover {
        background: rgba(255,255,255,.18);
    }

    .content {
        width: 86%;
        margin: 52px auto;
    }

    .section-heading {
        display: flex;
        justify-content: space-between;
        align-items: end;
        gap: 16px;
        margin-bottom: 24px;
    }

    .section-heading h2 {
        font-size: 27px;
        letter-spacing: -.7px;
        margin-bottom: 4px;
    }

    .section-heading p {
        color: #85899b;
        font-size: 14px;
    }

    .text-link {
        color: #6546e8;
        font-size: 14px;
        font-weight: 700;
        white-space: nowrap;
    }

    .text-link:hover {
        text-decoration: underline;
    }

    .category-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 18px;
    }

    .category-card {
        padding: 24px 20px;
        background: white;
        border: 1px solid #ececf4;
        border-radius: 19px;
        transition: .2s ease;
    }

    .category-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 12px 28px rgba(49, 39, 106, .08);
        border-color: #d9d0ff;
    }

    .category-icon {
        width: 52px;
        height: 52px;
        display: grid;
        place-items: center;
        border-radius: 15px;
        font-size: 25px;
        margin-bottom: 16px;
    }

    .purple { background: #eee9ff; }
    .orange { background: #fff0df; }
    .pink { background: #ffe8f0; }
    .blue { background: #e6f2ff; }

    .category-card h3 {
        font-size: 16px;
        margin-bottom: 5px;
    }

    .category-card p {
        color: #898da0;
        font-size: 13px;
    }

    .feature-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
    }

    .feature-card {
        background: white;
        padding: 27px;
        border-radius: 18px;
        border: 1px solid #ececf4;
    }

    .feature-number {
        color: #6546e8;
        font-size: 12px;
        font-weight: 800;
        letter-spacing: 1px;
    }

    .feature-card h3 {
        margin: 12px 0 8px;
        font-size: 18px;
    }

    .feature-card p {
        color: #777d91;
        font-size: 14px;
    }

    .bottom-cta {
        background: #eeebff;
        border: 1px solid #e3dcff;
        border-radius: 23px;
        padding: 36px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 24px;
        margin-top: 55px;
    }

    .bottom-cta h2 {
        font-size: 25px;
        margin-bottom: 6px;
    }

    .bottom-cta p {
        color: #72758d;
        font-size: 14px;
    }

    .cta-button {
        background: #6546e8;
        color: white;
        white-space: nowrap;
    }

    .cta-button:hover {
        background: #5033d0;
        transform: translateY(-2px);
    }

    footer {
        text-align: center;
        padding: 26px 15px;
        color: #9296a7;
        font-size: 12px;
        border-top: 1px solid #e9eaf2;
        background: white;
    }

    @media (max-width: 900px) {
        

        .hero {
            padding: 42px;
        }

        .category-grid {
            grid-template-columns: repeat(2, 1fr);
        }

        .feature-grid {
            grid-template-columns: 1fr;
        }
    }

    @media (max-width: 560px) {
       

        .hero, .content {
            width: 92%;
        }

        .hero {
            min-height: 400px;
            margin-top: 20px;
            padding: 28px;
            border-radius: 22px;
        }

        .hero h1 {
            font-size: 37px;
        }

        .hero p {
            font-size: 14px;
        }

        .section-heading {
            align-items: start;
            flex-direction: column;
        }

        .category-grid {
            gap: 12px;
        }

        .category-card {
            padding: 17px;
        }

        .bottom-cta {
            padding: 25px;
            align-items: start;
            flex-direction: column;
        }

        .nav-links {
            font-size: 13px;
        }
    }
</style>
</head>

<body>

 <jsp:include page="navbar.jsp" />

<section class="hero">
    <div class="hero-content">
        <div class="eyebrow">✦ YOUR NEXT EXPERIENCE STARTS HERE</div>

        <h1>Make plans.<br>
            Create <span>memories.</span></h1>

        <p>
            Discover exciting events, find experiences you love,
            and reserve your spot — all in one place.
        </p>

        <div class="hero-buttons">
            <a class="btn btn-primary"
               href="${pageContext.request.contextPath}/events">
                Explore Events &nbsp; →
            </a>

            <a class="btn btn-secondary"
               href="${pageContext.request.contextPath}/my-bookings">
                My Bookings
            </a>
        </div>
    </div>
</section>

<main class="content">

    <section>
        <div class="section-heading">
            <div>
                <h2>Find your kind of event</h2>
                <p>Something exciting is waiting for you.</p>
            </div>
            <a class="text-link"
               href="${pageContext.request.contextPath}/events">
                View all events →
            </a>
        </div>

        <div class="category-grid">
            <a class="category-card"
               href="${pageContext.request.contextPath}/events">
                <div class="category-icon purple">🎵</div>
                <h3>Music & Concerts</h3>
                <p>Live music and unforgettable nights</p>
            </a>

            <a class="category-card"
               href="${pageContext.request.contextPath}/events">
                <div class="category-icon orange">💻</div>
                <h3>Tech & Workshops</h3>
                <p>Learn, build and connect</p>
            </a>

            <a class="category-card"
               href="${pageContext.request.contextPath}/events">
                <div class="category-icon pink">🎨</div>
                <h3>Arts & Culture</h3>
                <p>Explore creativity and expression</p>
            </a>

            <a class="category-card"
               href="${pageContext.request.contextPath}/events">
                <div class="category-icon blue">🤝</div>
                <h3>Networking</h3>
                <p>Meet people and grow together</p>
            </a>
        </div>
    </section>

    <section style="margin-top: 55px;">
        <div class="section-heading">
            <div>
                <h2>A smoother way to attend events</h2>
                <p>Everything you need, from discovery to booking.</p>
            </div>
        </div>

        <div class="feature-grid">
            <div class="feature-card">
                <span class="feature-number">01 / DISCOVER</span>
                <h3>Find what excites you</h3>
                <p>Explore published events and check their dates,
                   venues, ticket prices and seat availability.</p>
            </div>

            <div class="feature-card">
                <span class="feature-number">02 / RESERVE</span>
                <h3>Book your tickets</h3>
                <p>Choose the event you want to attend and select
                   how many tickets you need.</p>
            </div>

            <div class="feature-card">
                <span class="feature-number">03 / ENJOY</span>
                <h3>Get ready for the day</h3>
                <p>Keep your booking details handy and get ready
                   to enjoy your next experience.</p>
            </div>
        </div>
    </section>

    <section class="bottom-cta">
        <div>
            <h2>Your next great experience is out there.</h2>
            <p>Browse available events and find your next favourite.</p>
        </div>

        <a class="btn cta-button"
           href="${pageContext.request.contextPath}/events">
            Browse Events →
        </a>
    </section>

</main>

<footer>
    © 2026 Eventify — Discover experiences. Make memories.
</footer>

</body>
</html>