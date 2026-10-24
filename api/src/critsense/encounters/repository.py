from collections.abc import Collection, Sequence

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from critsense.encounters.models import Monster


class MonsterRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def find_by_indexes(self, indexes: Collection[str]) -> dict[str, Monster]:
        """Monstros com os índices pedidos. Os índices que não existem ficam fora do resultado."""
        result = await self._session.scalars(select(Monster).where(Monster.index.in_(indexes)))
        return {monster.index: monster for monster in result}

    async def list_up_to_xp(self, max_xp: int) -> Sequence[Monster]:
        """Monstros que cabem num orçamento de ``max_xp``, do maior XP para o menor."""
        result = await self._session.scalars(
            select(Monster).where(Monster.xp <= max_xp).order_by(Monster.xp.desc(), Monster.index)
        )
        return result.all()
