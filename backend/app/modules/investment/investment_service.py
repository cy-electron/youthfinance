from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.common.exceptions import NotFoundException
from app.modules.investment.investment_model import Investment


class InvestmentService:

    @staticmethod
    def create(data):

        investment = Investment(
            user_id=get_jwt_identity(),
            **data
        )

        db.session.add(investment)
        db.session.commit()

        return investment

    @staticmethod
    def get_all():

        return Investment.query.filter_by(
            user_id=get_jwt_identity()
        ).all()

    @staticmethod
    def get_by_id(investment_id):

        investment = Investment.query.filter_by(
            id=investment_id,
            user_id=get_jwt_identity()
        ).first()

        if not investment:
            raise NotFoundException("Investment not found.")

        return investment

    @staticmethod
    def update(investment_id, data):

        investment = InvestmentService.get_by_id(
            investment_id
        )

        for key, value in data.items():
            setattr(investment, key, value)

        db.session.commit()

        return investment

    @staticmethod
    def delete(investment_id):

        investment = InvestmentService.get_by_id(
            investment_id
        )

        db.session.delete(investment)
        db.session.commit()