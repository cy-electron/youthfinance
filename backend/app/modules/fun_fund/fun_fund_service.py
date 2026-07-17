from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.common.exceptions import NotFoundException
from app.modules.fun_fund.fun_fund_model import FunFund


class FunFundService:

    @staticmethod
    def create(data):

        fund = FunFund(
            user_id=get_jwt_identity(),
            **data
        )

        db.session.add(fund)
        db.session.commit()

        return fund

    @staticmethod
    def get_all():

        return FunFund.query.filter_by(
            user_id=get_jwt_identity()
        ).all()

    @staticmethod
    def get_by_id(fun_fund_id):

        fund = FunFund.query.filter_by(
            id=fun_fund_id,
            user_id=get_jwt_identity()
        ).first()

        if not fund:
            raise NotFoundException(
                "Fun Fund not found."
            )

        return fund

    @staticmethod
    def update(fun_fund_id, data):

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        for key, value in data.items():
            setattr(fund, key, value)

        db.session.commit()

        return fund

    @staticmethod
    def delete(fun_fund_id):

        fund = FunFundService.get_by_id(
            fun_fund_id
        )

        db.session.delete(fund)
        db.session.commit()