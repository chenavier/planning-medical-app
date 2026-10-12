document.addEventListener('DOMContentLoaded', () => {
    const rows = document.querySelectorAll('.consultation-line');
    rows.forEach((row) => {
        row.addEventListener('mouseenter', () => {
            row.style.transform = 'translateX(2px)';
            row.style.transition = 'all 0.2s ease';
        });

        row.addEventListener('mouseleave', () => {
            row.style.transform = 'translateX(0)';
        });
    });
});
