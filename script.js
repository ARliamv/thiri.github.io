document.addEventListener('DOMContentLoaded', () => {

    /* ==========================================================================
       1. SMOOTH SCROLLING WITH NAVBAR OFFSET
       ========================================================================== */
    const navLinks = document.querySelectorAll('.nav-links a[href^="#"], .hero-cta a[href^="#"]');

    navLinks.forEach(link => {
        link.addEventListener('click', function (e) {
            e.preventDefault();

            const targetId = this.getAttribute('href');
            if (targetId === '#') return;

            const targetElement = document.querySelector(targetId);

            if (targetElement) {
                // Account for fixed navigation bar height
                const navHeight = document.querySelector('.navbar').offsetHeight;
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - navHeight - 20;

                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    /* ==========================================================================
       2. SCROLL-REVEAL ANIMATIONS FOR CARDS
       ========================================================================== */
    const observerOptions = {
        root: null,
        rootMargin: '0px 0px -50px 0px',
        threshold: 0.15
    };

    const revealOnScroll = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('reveal-active');
                // Stop observing once animated
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Elements to animate on scroll
    const animatedElements = document.querySelectorAll(
        '.project-card, .skill-card, .learning-card, .certificate-card'
    );

    animatedElements.forEach(el => {
        el.classList.add('reveal-hidden');
        revealOnScroll.observe(el);
    });

    /* ==========================================================================
       3. BACK TO TOP BUTTON
       ========================================================================== */
    const backToTopBtn = document.createElement('button');
    backToTopBtn.id = 'backToTop';
    backToTopBtn.innerHTML = '&#8593;';
    backToTopBtn.setAttribute('aria-label', 'Back to Top');
    document.body.appendChild(backToTopBtn);

    window.addEventListener('scroll', () => {
        if (window.pageYOffset > 400) {
            backToTopBtn.classList.add('show');
        } else {
            backToTopBtn.classList.remove('show');
        }
    });

    backToTopBtn.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
});

/* ==========================================================================
   4. CERTIFICATE IMAGE POPUP (LIGHTBOX MODAL)
   ========================================================================== */
document.addEventListener('DOMContentLoaded', () => {
    const modal = document.getElementById('certModal');
    const modalImg = document.getElementById('certModalImg');
    const closeBtn = document.querySelector('.cert-modal-close');
    const certButtons = document.querySelectorAll('.cert-btn');

    // Open image modal for certificates
    certButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const imgSrc = e.target.getAttribute('data-img');
            if (imgSrc) {
                modalImg.src = imgSrc;
                modal.style.display = 'flex';
            }
        });
    });

    // Close modal actions
    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            modal.style.display = 'none';
        });
    }

    if (modal) {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.style.display = 'none';
            }
        });
    }
});