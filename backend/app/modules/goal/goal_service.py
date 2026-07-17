from flask_jwt_extended import get_jwt_identity

from app.extensions import db
from app.modules.goal.goal_model import Goal
from app.common.exceptions import NotFoundException


class GoalService:

    @staticmethod
    def create_goal(data):

        goal = Goal(
            user_id=get_jwt_identity(),
            title=data["title"],
            target_amount=data["target_amount"],
            current_amount=data.get("current_amount", 0),
            target_date=data["target_date"],
            description=data.get("description")
        )

        db.session.add(goal)
        db.session.commit()

        return goal

    @staticmethod
    def get_all_goals():

        return Goal.query.filter_by(
            user_id=get_jwt_identity()
        ).order_by(
            Goal.target_date.asc()
        ).all()

    @staticmethod
    def get_goal(goal_id):

        goal = Goal.query.filter_by(
            id=goal_id,
            user_id=get_jwt_identity()
        ).first()

        if not goal:
            raise NotFoundException("Goal not found.")

        return goal

    @staticmethod
    def update_goal(goal_id, data):

        goal = GoalService.get_goal(goal_id)

        for key, value in data.items():
            setattr(goal, key, value)

        if goal.current_amount >= goal.target_amount:
            goal.is_completed = True

        db.session.commit()

        return goal

    @staticmethod
    def delete_goal(goal_id):

        goal = GoalService.get_goal(goal_id)

        db.session.delete(goal)
        db.session.commit()