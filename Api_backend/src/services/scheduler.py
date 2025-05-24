from apscheduler.triggers.interval import IntervalTrigger
from .spotify_sync import SpotifySync
from ..extensions import scheduler
import logging
import atexit

logger = logging.getLogger(__name__)

def init_scheduler(app):
    """Inicializa el scheduler para tareas automáticas"""
    
    # Tarea que se ejecuta cada hora
    scheduler.add_job(
        func=SpotifySync.generate_hourly_stats,
        trigger="interval",
        hours=1,
        id='hourly_stats',
        name='Generar estadísticas horarias',
        replace_existing=True
    )
    
    logger.info("Scheduler configurado - Sincronización automática activada")
    
    # Asegurar que se cierre correctamente
    atexit.register(lambda: scheduler.shutdown() if scheduler.running else None)
    
    return scheduler 